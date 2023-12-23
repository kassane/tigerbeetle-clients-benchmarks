#!/usr/bin/env bash

../tigerbeetle/zig/zig build run \
    -Doptimize=ReleaseSafe \
    -freference-trace \
    --prominent-compile-errors
