package main

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
)

func xochitl(ctx context.Context) (kill func() error, result chan error) {
	result = make(chan error, 1)

	var stdErr bytes.Buffer

	cmd := exec.CommandContext(ctx, "xochitl", "--system")
	cmd.Stderr = &stdErr

	err := cmd.Start()
	if err != nil {
		result <- fmt.Errorf("starting mount: %w", err)
		close(result)

		return nil, result
	}

	go func() {
		err := cmd.Wait()
		if err != nil {
			exitErr, ok := err.(*exec.ExitError) //nolint:errorlint
			if ok {
				err = fmt.Errorf("error code %d: %s", exitErr.ExitCode(), stdErr.String())
			}
		}

		result <- err
		close(result)
	}()

	return cmd.Process.Kill, result
}
