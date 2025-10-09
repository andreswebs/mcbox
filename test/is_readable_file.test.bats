#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "is_readable_file: readable existing file" {
    # Create a temporary file
    local test_file="${BATS_TEST_TMPDIR}/readable_test_file.txt"
    echo "test content" >"${test_file}"

    run is_readable_file "${test_file}"
    assert_success
}

@test "is_readable_file: non-existent file" {
    local non_existent_file="${BATS_TEST_TMPDIR}/non_existent_file.txt"

    run is_readable_file "${non_existent_file}"
    assert_failure
}

@test "is_readable_file: directory instead of file" {
    run is_readable_file "${BATS_TEST_TMPDIR}"
    assert_failure
}

@test "is_readable_file: empty string argument" {
    run is_readable_file ""
    assert_failure
}

@test "is_readable_file: file with spaces in name" {
    local test_file="${BATS_TEST_TMPDIR}/file with spaces.txt"
    echo "test content" >"${test_file}"

    run is_readable_file "${test_file}"
    assert_success
}

@test "is_readable_file: unreadable file" {
    local test_file="${BATS_TEST_TMPDIR}/unreadable_file.txt"
    echo "test content" >"${test_file}"
    chmod 000 "${test_file}"

    run is_readable_file "${test_file}"
    assert_failure

    # Cleanup: restore permissions for deletion
    chmod 644 "${test_file}"
}

@test "is_readable_file: relative path resolution" {
    # Create a file in current directory
    local test_file="./test_relative_file.txt"
    echo "test content" >"${test_file}"

    run is_readable_file "${test_file}"
    assert_success

    # Cleanup
    rm -f "${test_file}"
}

@test "is_readable_file: symlink to readable file" {
    local test_file="${BATS_TEST_TMPDIR}/target_file.txt"
    local symlink_file="${BATS_TEST_TMPDIR}/symlink_file.txt"

    echo "test content" >"${test_file}"
    ln -s "${test_file}" "${symlink_file}"

    run is_readable_file "${symlink_file}"
    assert_success
}

@test "is_readable_file: broken symlink" {
    local non_existent_target="${BATS_TEST_TMPDIR}/non_existent_target.txt"
    local symlink_file="${BATS_TEST_TMPDIR}/broken_symlink.txt"

    ln -s "${non_existent_target}" "${symlink_file}"

    run is_readable_file "${symlink_file}"
    assert_failure
}

@test "is_readable_file: blocks malicious command injection" {
    # Test that paths with command injection are blocked
    # shellcheck disable=SC2016
    local malicious_path='$(echo malicious); echo /etc/passwd'

    run is_readable_file "${malicious_path}"
    assert_failure
}

@test "is_readable_file: blocks paths with unsafe characters" {
    # Test various unsafe character combinations
    # shellcheck disable=SC2016
    local unsafe_paths=(
        '$(rm -rf /tmp/root-was-wiped)'
        '`touch /tmp/hacked`'
        '|cat /etc/passwd'
        ';echo dangerous'
        '&&echo injected'
        '||echo fallback'
        '*dangerous*'
        '?unsafe?'
        '[injection]'
        '{expansion}'
    )

    for unsafe_path in "${unsafe_paths[@]}"; do
        run is_readable_file "${unsafe_path}"
        assert_failure
    done
}
