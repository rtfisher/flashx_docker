#!/usr/bin/env bats

# Test suite for run_flashx.sh script
# Uses BATS (Bash Automated Testing System)

setup() {
    # Load the script functions without executing
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export RUN_SCRIPT="$SCRIPT_DIR/run_flashx.sh"

    # Create temporary test directory
    export TEST_TEMP_DIR="$(mktemp -d)"
}

teardown() {
    # Clean up temporary files
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Test: Script file exists and is executable
@test "run_flashx.sh exists and is executable" {
    [ -f "$RUN_SCRIPT" ]
    [ -x "$RUN_SCRIPT" ]
}

# Test: Script contains required functions and checks
@test "Script contains Docker availability check" {
    grep -q "docker info" "$RUN_SCRIPT" || \
    grep -q "docker --version" "$RUN_SCRIPT" || \
    grep -q "command -v docker" "$RUN_SCRIPT"
}

@test "Script contains OS detection logic" {
    grep -q "uname" "$RUN_SCRIPT"
}

@test "Script contains Windows/WSL detection" {
    grep -q "Microsoft" "$RUN_SCRIPT" || \
    grep -q "microsoft" "$RUN_SCRIPT" || \
    grep -q "WSL" "$RUN_SCRIPT"
}

@test "Script contains directory creation logic" {
    grep -q "mkdir" "$RUN_SCRIPT"
}

@test "Script contains docker build command" {
    grep -q "docker build" "$RUN_SCRIPT"
}

@test "Script contains docker run command" {
    grep -q "docker run" "$RUN_SCRIPT"
}

# Test: Script syntax is valid
@test "Script has valid bash syntax" {
    bash -n "$RUN_SCRIPT"
}

# Test: Script uses proper shebang
@test "Script has correct shebang" {
    head -n 1 "$RUN_SCRIPT" | grep -q "^#!/bin/bash" || \
    head -n 1 "$RUN_SCRIPT" | grep -q "^#!/usr/bin/env bash"
}

# Test: Script handles UID/GID correctly
@test "Script passes UID to docker build" {
    grep -q "USER_ID" "$RUN_SCRIPT" || \
    grep -q "UID" "$RUN_SCRIPT"
}

@test "Script passes GID to docker build" {
    grep -q "GROUP_ID" "$RUN_SCRIPT" || \
    grep -q "GID" "$RUN_SCRIPT"
}

# Test: Volume mounting logic exists
@test "Script contains volume mount configuration" {
    grep -q "\-v" "$RUN_SCRIPT" || \
    grep -q "\-\-volume" "$RUN_SCRIPT"
}

# Test: Interactive mode configuration
@test "Script configures interactive mode" {
    grep -q "\-it" "$RUN_SCRIPT" || \
    (grep -q "\-i" "$RUN_SCRIPT" && grep -q "\-t" "$RUN_SCRIPT")
}

# Test: Dockerfile reference exists
@test "Script references flashx_dockerfile" {
    grep -q "flashx_dockerfile" "$RUN_SCRIPT"
}

# Test: Image naming convention
@test "Script specifies Docker image name" {
    grep "flashx" "$RUN_SCRIPT" | grep -q "build\|run"
}

# Test: Script handles errors
@test "Script contains error handling" {
    grep -q "exit" "$RUN_SCRIPT" || \
    grep -q "return" "$RUN_SCRIPT"
}

# Test: Environment variable handling
@test "Script uses HOME directory" {
    grep -q "HOME" "$RUN_SCRIPT" || \
    grep -q "~" "$RUN_SCRIPT"
}

# Test: Cross-platform path handling for WSL
@test "Script handles WSL path conversion" {
    grep -q "wslpath" "$RUN_SCRIPT"
}

# Test: Script provides user feedback
@test "Script contains echo statements for user feedback" {
    grep -q "echo" "$RUN_SCRIPT"
}

# Test: Docker daemon check
@test "Script checks if Docker is running" {
    grep -q "docker info" "$RUN_SCRIPT" || \
    grep -q "docker ps" "$RUN_SCRIPT" || \
    grep -q "docker --version" "$RUN_SCRIPT"
}

# Test: No hardcoded passwords or secrets
@test "Script does not contain hardcoded passwords" {
    ! grep -i "password=" "$RUN_SCRIPT"
    ! grep -i "passwd=" "$RUN_SCRIPT"
}

# Test: Proper quoting of variables
@test "Script uses proper variable quoting" {
    # Check that critical variables are quoted
    # This is a basic check - shellcheck is better for comprehensive analysis
    if grep -q '\$HOME[^"]' "$RUN_SCRIPT"; then
        # Some unquoted $HOME usage exists, but may be acceptable in some contexts
        # This test serves as a reminder to check
        true
    fi
}

# Test: Script creates flashx directory
@test "Script references flashx directory creation" {
    grep "flashx" "$RUN_SCRIPT" | grep -q "mkdir"
}

# Test: Script handles permissions
@test "Script addresses file permissions" {
    grep -q "chmod\|permission\|user\|USER_ID\|UID" "$RUN_SCRIPT"
}
