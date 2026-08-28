#!/usr/bin/env bash

basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
