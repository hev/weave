package main

import (
	"fmt"
	"github.com/hev/weave/internal/weave"
	"os"
)

func main() {
	if err := weave.Run(os.Args[1:], os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, "weave:", err)
		os.Exit(1)
	}
}
