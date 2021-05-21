package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"
)

const (
	maxImmediateRestarts = 3
	immediateRestartTime = 10 * time.Second
	rootDir              = "/home/crypto"
	mountPoint           = "/home/root"
	listenAddress        = "0.0.0.0:1234"
	frameBufferClientSO  = "/home/crypto/lib/librm2fb_client.so"
)

var (
	binDir   = filepath.Join(rootDir, "bin")
	cryptoFS = filepath.Join(rootDir, "fs")
)

func main() {
	logger := NewLogger(os.Stdout, "")

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	cm, err := NewCryptoMount(cryptoFS, mountPoint, logger)
	if err != nil {
		logger.Printf("creating crypto mount: 	%v", err)

		return
	}

	for {
		err := run(ctx, cm, logger)
		if nil == err {
			continue
		}

		if errors.Is(err, ErrPassphraseIncorrect) {
			logger.Printf("passphrase incorrect, retrying...")

			continue
		}

		if isCancelled(ctx) {
			printErr := display(context.Background(), "Cryptodaemon Stopped", "")
			if printErr != nil {
				logger.Printf("cannot display fatal error on screen: %v", printErr)
			}

			return
		}

		printErr := display(ctx, "Fatal Error:", err.Error())
		if printErr != nil {
			logger.Printf("cannot display fatal error on screen: %v", printErr)
		}

		logger.Printf("fatal error: %v", err)

		return
	}
}

// nolint:cyclop
func run(ctx context.Context, cm *CryptoMount, logger *Logger) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	logger.Println("mounting crypto filesystem")

	err := cm.Mount(ctx)
	if err != nil {
		return fmt.Errorf("mount: %w", err)
	}

	defer func() {
		err = cm.Unmount()
		if err != nil {
			log.Printf("cannot unmount: %v", err)
		}
	}()

	var (
		recentRestarts int
		lastRestart    time.Time
	)

	for {
		if isCancelled(ctx) {
			return ctx.Err()
		}

		if time.Now().After(lastRestart.Add(immediateRestartTime)) {
			recentRestarts = 0
		}

		if recentRestarts >= maxImmediateRestarts {
			return fmt.Errorf("terminating after %d restarts within 10s of each other", maxImmediateRestarts)
		}

		recentRestarts++

		lastRestart = time.Now()

		logger.Printf("starting xochitl")

		killGui, guiTerminated := xochitl(ctx)

		select {
		case <-cm.Terminated:
			logger.Printf("mount process terminated, killing xochitl")

			err := killGui()
			if err != nil {
				return fmt.Errorf("cannot kill xochitl after mount process died: %w", err)
			}

			<-guiTerminated

			err = cm.Unmount()
			if err != nil {
				return fmt.Errorf("unmounting after mount process died: %w", err)
			}

			return ctx.Err()
		case <-guiTerminated:
			if ctx.Err() != nil {
				<-cm.Terminated

				return ctx.Err()
			}

			logger.Println("GUI terminated, restarting...")
		}
	}
}

func isCancelled(ctx context.Context) bool {
	return ctx.Err() != nil
}

// Logger is a log.Logger without flags that implements io.Writer.
type Logger struct {
	*log.Logger
}

// NewLogger returns a new Logger.
func NewLogger(out io.Writer, prefix string) *Logger {
	return &Logger{Logger: log.New(out, prefix, 0)}
}

// Write implements io.Writer for Logger.
func (l *Logger) Write(data []byte) (int, error) {
	for _, part := range bytes.Split(bytes.TrimSpace(data), []byte("\n")) {
		l.Print(string(part))
	}

	return len(data), nil
}
