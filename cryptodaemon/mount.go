package main

import (
	"bufio"
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

const defaultMountTimeout = 5 * time.Second

// ErrPassphraseIncorrect is emitted when it is attempted to mount the crypto
// filesystem with the wrong passphrase.
var ErrPassphraseIncorrect = fmt.Errorf("passphrase incorrect")

// CryptoMount represents and encrypted filesystem and
// a corresponding plaintext mount point.
type CryptoMount struct {
	Timeout                time.Duration
	cryptoFS               string
	mountPoint             string
	cachedPassphrase       string
	passphraseWasIncorrect bool

	Terminated chan error

	log *Logger
}

// NewCryptoMount creates a new plaintext mount based from a encrypted filesystem.
func NewCryptoMount(cryptoFS, mountPoint string, logWriter io.Writer) (*CryptoMount, error) {
	cryptoFS, err := filepath.Abs(cryptoFS)
	if err != nil {
		return nil, fmt.Errorf("determine absolute crypto fs path: %w", err)
	}

	_, err = os.Stat(cryptoFS)
	if err != nil {
		return nil, fmt.Errorf("cannot stat crypto filesystem directory: %w", err)
	}

	mountPoint, err = filepath.Abs(mountPoint)
	if err != nil {
		return nil, fmt.Errorf("determine absolute mount path: %w", err)
	}

	_, err = os.Stat(mountPoint)
	if err != nil {
		return nil, fmt.Errorf("cannot stat mount point: %w", err)
	}

	return &CryptoMount{
		Timeout:    defaultMountTimeout,
		cryptoFS:   cryptoFS,
		mountPoint: mountPoint,

		log: NewLogger(logWriter, "crypto mount: "),
	}, nil
}

// Mounted returns true the crypto mount is already mounted.
func (cm *CryptoMount) Mounted() (bool, error) {
	f, err := os.Open("/proc/mounts")
	if err != nil {
		return false, fmt.Errorf("open: %w", err)
	}

	defer func() { _ = f.Close() }()

	sc := bufio.NewScanner(f)

	for sc.Scan() {
		if sc.Err() != nil {
			return false, fmt.Errorf("scan: %w", err)
		}

		fields := strings.Fields(sc.Text())

		if fields[0] == cm.cryptoFS && fields[1] == cm.mountPoint && fields[2] == "fuse.gocryptfs" {
			return true, nil
		}
	}

	return false, nil
}

// Mount mounts the decrypted filesystem to the specified mount point.
// If it is already mounted at that mount point it does nothing.
func (cm *CryptoMount) Mount(ctx context.Context) error {
	var err error

	passphrase := cm.cachedPassphrase
	if passphrase == "" {
		passphrase, err = getPassphrase(ctx, cm.log, cm.passphraseWasIncorrect)
		if err != nil {
			return err
		}
	}

	err = cm.mount(ctx, passphrase)
	if err != nil {
		if errors.Is(err, ErrPassphraseIncorrect) {
			cm.passphraseWasIncorrect = true
		}

		return err
	}

	// remember correct passphrase
	cm.cachedPassphrase = passphrase
	cm.passphraseWasIncorrect = false

	return nil
}

func (cm *CryptoMount) mount(ctx context.Context, passphrase string) error { //nolint:cyclop
	if err := ctx.Err(); err != nil {
		return err
	}

	alreadyMounted, err := cm.Mounted()
	if err != nil {
		return fmt.Errorf("determine whether %s is already mounted: %w", cm.mountPoint, err)
	}

	if alreadyMounted {
		return fmt.Errorf("crypto filesystem is already mounted")
	}

	cm.Terminated = make(chan error, 1)

	var stdErr bytes.Buffer

	//nolint:gosec
	cmd := exec.CommandContext(ctx, findExecutable("gocryptfs"), "-fg", "-nonempty",
		fmt.Sprintf("-notifypid=%d", os.Getpid()), cm.cryptoFS, mountPoint)

	cmd.Env = environmentWithCustomBinaries()
	cmd.Stdout = NewLogger(cm.log, "gocryptfs: ")
	cmd.Stdin = strings.NewReader(passphrase + "\n")
	cmd.Stderr = &stdErr

	ready := make(chan os.Signal, 1)

	signal.Notify(ready, syscall.SIGUSR1)

	err = cmd.Start()
	if err != nil {
		return fmt.Errorf("starting mount: %w", err)
	}

	go func() {
		err := cmd.Wait()
		if err != nil {
			err = wrapMountError(err, stdErr.String())
		}

		cm.Terminated <- err
		close(cm.Terminated)
	}()

	timer := time.NewTimer(defaultMountTimeout)
	defer timer.Stop()

	select {
	case <-ready:
		mounted, err := cm.Mounted()
		if err != nil {
			_ = cmd.Process.Kill()

			return fmt.Errorf("checking mount status after mounting: %w", err)
		}

		if !mounted {
			_ = cmd.Process.Kill()

			return fmt.Errorf("mount process did not produce a mount at %s", cm.mountPoint)
		}

		return nil
	case err := <-cm.Terminated:
		return err
	case <-timer.C:
		err := cmd.Process.Kill()
		if err != nil {
			return fmt.Errorf("kill process after timeout: %w", err)
		}

		return fmt.Errorf("mount timeout exceeded")
	}
}

func wrapMountError(err error, stdErr string) error {
	if exitErr, ok := err.(*exec.ExitError); ok { //nolint:errorlint
		if strings.Contains(strings.ToLower(stdErr), "password incorrect") {
			return ErrPassphraseIncorrect
		}

		return fmt.Errorf("error code %d: %s", exitErr.ExitCode(), stdErr)
	}

	return err
}

// environmentWithCustomBinaries returns the current environment variables
// with the PATH variable modified to include in directory with the binaries
// required by the cryptodaemon.
func environmentWithCustomBinaries() []string {
	parentEnv := os.Environ()

	env := make([]string, 0, len(parentEnv))

	hasPATH := false

	for _, variable := range parentEnv {
		if strings.HasPrefix(variable, "PATH=") {
			hasPATH = true
			variable = variable + ":" + binDir
		}

		env = append(env, variable)
	}

	if !hasPATH {
		env = append(env, "PATH="+binDir)
	}

	return env
}

// Unmount unmounts the crypto filesystem. If it was not mounted
// yet it does nothing.
func (cm *CryptoMount) Unmount() error {
	stillMounted, err := cm.Mounted()
	if err != nil {
		return fmt.Errorf("determine whether mountPoint is already mounted: %w", err)
	}

	if !stillMounted {
		return nil
	}

	var stdErr bytes.Buffer

	//nolint:gosec
	cmd := exec.Command(findExecutable("fusermount"), "-u", mountPoint)
	cmd.Stderr = &stdErr
	cmd.Stdout = NewLogger(cm.log, "fusermount: ")

	err = cmd.Run()
	if err != nil {
		exitErr, ok := err.(*exec.ExitError) //nolint:errorlint
		if ok {
			return fmt.Errorf("error code %d: %s", exitErr.ExitCode(), stdErr.String())
		}

		return err
	}

	mounted, err := cm.Mounted()
	if err != nil {
		return fmt.Errorf("checking mount status after mounting: %w", err)
	}

	if mounted {
		return fmt.Errorf("mount point at %s is still present after unmounting", cm.mountPoint)
	}

	cm.log.Printf("unmounted %s", cm.mountPoint)

	return nil
}

func findExecutable(bin string) string {
	_, err := os.Stat(filepath.Join(binDir, bin))
	if err == nil {
		return filepath.Join(binDir, bin)
	}

	return bin
}
