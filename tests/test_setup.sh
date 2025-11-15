#!/usr/bin/env bash

# Test suite for machine-setup
# Basic tests to verify script functionality

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Test logging
test_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

test_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

test_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Test: Check if required files exist
test_required_files() {
    test_info "Testing required files..."

    local required_files=(
        "setup.sh"
        "README.md"
        "CLAUDE.md"
        "lib/common.sh"
        "lib/preflight.sh"
        "config/versions.conf"
        "config/profiles/minimal.conf"
        "config/profiles/full.conf"
        "config/profiles/k8s-dev.conf"
        "scripts/doctor.sh"
        "scripts/update.sh"
        "scripts/uninstall.sh"
        ".shellcheckrc"
        ".github/workflows/ci.yml"
    )

    for file in "${required_files[@]}"; do
        if [ -f "$SCRIPT_DIR/$file" ]; then
            test_pass "File exists: $file"
        else
            test_fail "File missing: $file"
        fi
    done
}

# Test: Check if scripts are executable
test_executables() {
    test_info "Testing script executables..."

    local executables=(
        "setup.sh"
        "scripts/doctor.sh"
        "scripts/update.sh"
        "scripts/uninstall.sh"
    )

    for script in "${executables[@]}"; do
        if [ -x "$SCRIPT_DIR/$script" ]; then
            test_pass "Script is executable: $script"
        else
            test_fail "Script is NOT executable: $script"
        fi
    done
}

# Test: Verify shell syntax
test_syntax() {
    test_info "Testing shell script syntax..."

    local scripts=(
        "setup.sh"
        "lib/common.sh"
        "lib/preflight.sh"
        "scripts/doctor.sh"
        "scripts/update.sh"
        "scripts/uninstall.sh"
    )

    for script in "${scripts[@]}"; do
        if bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
            test_pass "Syntax valid: $script"
        else
            test_fail "Syntax error in: $script"
        fi
    done
}

# Test: Common library functions
test_common_lib() {
    test_info "Testing common library..."

    # Source the library
    if source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null; then
        test_pass "common.sh can be sourced"
    else
        test_fail "Cannot source common.sh"
        return
    fi

    # Test if key functions exist
    if declare -f log_info >/dev/null 2>&1; then
        test_pass "Function exists: log_info"
    else
        test_fail "Function missing: log_info"
    fi

    if declare -f detect_os >/dev/null 2>&1; then
        test_pass "Function exists: detect_os"
    else
        test_fail "Function missing: detect_os"
    fi

    if declare -f command_exists >/dev/null 2>&1; then
        test_pass "Function exists: command_exists"
    else
        test_fail "Function missing: command_exists"
    fi

    # Test detect_os function
    local detected_os
    detected_os=$(detect_os)
    if [ -n "$detected_os" ]; then
        test_pass "detect_os returned: $detected_os"
    else
        test_fail "detect_os returned empty"
    fi
}

# Test: Profile configurations
test_profiles() {
    test_info "Testing profile configurations..."

    local profiles=("minimal" "full" "k8s-dev")

    for profile in "${profiles[@]}"; do
        local profile_file="$SCRIPT_DIR/config/profiles/${profile}.conf"

        if [ -f "$profile_file" ]; then
            # Check if profile has required variables
            if grep -q "oh_my_zsh=" "$profile_file"; then
                test_pass "Profile $profile has oh_my_zsh setting"
            else
                test_fail "Profile $profile missing oh_my_zsh setting"
            fi

            if grep -q "python=" "$profile_file"; then
                test_pass "Profile $profile has python setting"
            else
                test_fail "Profile $profile missing python setting"
            fi
        else
            test_fail "Profile file missing: ${profile}.conf"
        fi
    done
}

# Test: Version configuration
test_versions() {
    test_info "Testing version configuration..."

    local versions_file="$SCRIPT_DIR/config/versions.conf"

    if [ -f "$versions_file" ]; then
        # Check if key version variables exist
        if grep -q "PYTHON_VERSION=" "$versions_file"; then
            test_pass "versions.conf has PYTHON_VERSION"
        else
            test_fail "versions.conf missing PYTHON_VERSION"
        fi

        if grep -q "KUBECTL_VERSION=" "$versions_file"; then
            test_pass "versions.conf has KUBECTL_VERSION"
        else
            test_fail "versions.conf missing KUBECTL_VERSION"
        fi

        if grep -q "GRANTED_VERSION=" "$versions_file"; then
            test_pass "versions.conf has GRANTED_VERSION"
        else
            test_fail "versions.conf missing GRANTED_VERSION"
        fi
    else
        test_fail "versions.conf not found"
    fi
}

# Test: Documentation
test_documentation() {
    test_info "Testing documentation..."

    # Check README
    if grep -q "## Features" "$SCRIPT_DIR/README.md"; then
        test_pass "README has Features section"
    else
        test_fail "README missing Features section"
    fi

    if grep -q "## Quick Start" "$SCRIPT_DIR/README.md"; then
        test_pass "README has Quick Start section"
    else
        test_fail "README missing Quick Start section"
    fi

    # Check CLAUDE.md
    if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
        test_pass "CLAUDE.md exists"
    else
        test_fail "CLAUDE.md missing"
    fi
}

# Test: Directory structure
test_directory_structure() {
    test_info "Testing directory structure..."

    local required_dirs=(
        "lib"
        "config"
        "config/profiles"
        "scripts"
        "tests"
        ".github"
        ".github/workflows"
    )

    for dir in "${required_dirs[@]}"; do
        if [ -d "$SCRIPT_DIR/$dir" ]; then
            test_pass "Directory exists: $dir"
        else
            test_fail "Directory missing: $dir"
        fi
    done
}

# Test: Preflight checks library
test_preflight() {
    test_info "Testing preflight library..."

    # Source common first
    source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || true

    # Source the preflight library
    if source "$SCRIPT_DIR/lib/preflight.sh" 2>/dev/null; then
        test_pass "preflight.sh can be sourced"
    else
        test_fail "Cannot source preflight.sh"
        return
    fi

    # Test if key functions exist
    if declare -f check_disk_space >/dev/null 2>&1; then
        test_pass "Function exists: check_disk_space"
    else
        test_fail "Function missing: check_disk_space"
    fi

    if declare -f check_internet >/dev/null 2>&1; then
        test_pass "Function exists: check_internet"
    else
        test_fail "Function missing: check_internet"
    fi
}

# Main test runner
main() {
    echo "======================================"
    echo "  Machine Setup - Test Suite"
    echo "======================================"
    echo ""

    # Run all tests
    test_directory_structure
    echo ""
    test_required_files
    echo ""
    test_executables
    echo ""
    test_syntax
    echo ""
    test_common_lib
    echo ""
    test_preflight
    echo ""
    test_profiles
    echo ""
    test_versions
    echo ""
    test_documentation
    echo ""

    # Summary
    echo "======================================"
    echo "  Test Summary"
    echo "======================================"
    echo ""
    echo "Total tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo ""

    # Calculate success rate
    if [ $TOTAL_TESTS -gt 0 ]; then
        local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo "Success rate: ${success_rate}%"
    fi
    echo ""

    # Exit with appropriate code
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run tests
main
