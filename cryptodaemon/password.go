package main

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"log"
	"net"
	"os/exec"
	"strings"
)

func passphraseFromNet(ctx context.Context, addr string, logWriter io.Writer) (chan string, error) {
	logger := log.New(logWriter, "passphrase from netwok: ", 0)

	passwordChan := make(chan string, 1)

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return passwordChan, fmt.Errorf("listen: %w", err)
	}

	logger.Printf("started listener on %s", addr)

	ctx, cancel := context.WithCancel(ctx)

	go func() {
		<-ctx.Done()

		logger.Printf("closing listener on %s", addr)

		_ = listener.Close()
	}()

	go func() {
		defer cancel()

		for {
			conn, err := listener.Accept()
			if err != nil {
				if ctx.Err() != nil {
					return
				}

				logger.Printf("accepting network connection: %v", err)
			}

			rawPassphrase, err := io.ReadAll(conn)
			if err != nil {
				logger.Printf("reading passphrase from connection: %v", err)

				_ = conn.Close()

				continue
			}

			_ = conn.Close()

			passwordChan <- strings.TrimSuffix(string(rawPassphrase), "\n")

			return
		}
	}()

	return passwordChan, nil
}

func passphraseFromGUI(ctx context.Context, logWriter io.Writer, notifyIncorrect bool) (chan string, error) {
	logger := NewLogger(logWriter, "passphrase from GUI: ")

	outputChan := make(chan string, 1)

	var stdOut bytes.Buffer

	var args []string
	if notifyIncorrect {
		args = append(args, "incorrect")
	}

	cmd := qtApplication(ctx, "password_prompt", args...)

	cmd.Stdout = &stdOut
	cmd.Stderr = NewLogger(logger, "password_prompt: ")

	err := clearScreen(ctx)
	if err != nil {
		return outputChan, fmt.Errorf("clearing screen before password prompt: %w", err)
	}

	err = cmd.Start()
	if err != nil {
		return outputChan, fmt.Errorf("starting password_prompt: %w", err)
	}

	logger.Printf("started passwort prompt application")

	go func() {
		err := cmd.Wait()
		if err != nil && ctx.Err() != nil {
			logger.Printf("application terminated unexpectedly: %v", err)

			return
		}

		err = clearScreen(ctx)
		if err != nil {
			logger.Printf("clearing screen after password prompt: %v", err)

			return
		}

		outputChan <- strings.TrimSuffix(stdOut.String(), "\n")
	}()

	return outputChan, nil
}

func getPassphrase(ctx context.Context, logWriter io.Writer, notifyIncorrect bool) (string, error) {
	logger := NewLogger(logWriter, "")

	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	fromGUI, guiErr := passphraseFromGUI(ctx, logger, notifyIncorrect)
	if guiErr != nil {
		logger.Printf("cannot get passphrase from GUI: %v", guiErr)
	}

	fromNet, netErr := passphraseFromNet(ctx, listenAddress, logger)
	if netErr != nil {
		logger.Printf("cannot get passphrase from network: %v", netErr)
	}

	if guiErr != nil && netErr != nil {
		return "", fmt.Errorf("no input methods available")
	}

	var password string

	select {
	case c := <-fromGUI:
		logger.Printf("received passphrase from GUI")

		password = c
	case c := <-fromNet:
		logger.Printf("received passphrase from network")

		password = c
	case <-ctx.Done():
		return "", ctx.Err()
	}

	return password, nil
}

func qtApplication(ctx context.Context, name string, args ...string) exec.Cmd {
	cmd := exec.CommandContext(ctx, findExecutable(name), args...) // nolint:gosec

	cmd.Env = append(environmentWithCustomBinaries(), "LD_PRELOAD="+frameBufferClientSO)

	return *cmd
}

func clearScreen(ctx context.Context) error {
	cmd := qtApplication(ctx, "print")

	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("executing print: %w\n%s", err, string(out))
	}

	return nil
}

func display(ctx context.Context, title string, subtitle string) error {
	args := []string{title}
	if subtitle != "" {
		args = append(args, subtitle)
	}

	cmd := qtApplication(ctx, "print", args...)

	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("executing print: %w\n%s", err, string(out))
	}

	return nil
}
