#!/usr/bin/env bats

load '../mcbox-core.bash'
load '../defaults/tools.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "tool_file_size: works with valid file" {
    local test_file="${BATS_TEST_TMPDIR}/test_file.txt"
    echo "test content" >"${test_file}"

    run tool_file_size "{\"path\":\"${test_file}\"}"
    assert_success
    assert_output --partial '"path":'
    assert_output --partial '"size":'
}

@test "tool_file_size: fails with environment variable expansion" {
    local test_file="${BATS_TEST_TMPDIR}/test_file.txt"
    echo "test content" >"${test_file}"

    run tool_file_size "{\"path\":\"\${BATS_TEST_TMPDIR}/test_file.txt\"}"
    assert_failure
}

@test "tool_file_size: blocks malicious command injection" {
    # Test the exact malicious input from the user's example
    run tool_file_size "{\"path\":\"\$(echo malicious); echo /etc/passwd\"}"
    assert_failure

    # Should not contain the malicious path in error messages (security)
    refute_output --partial 'echo malicious'
    refute_output --partial '/etc/passwd'
    # Should only contain generic error message
    assert_output --partial "file not accessible"
}

@test "tool_file_size: blocks various unsafe path patterns" {
    # shellcheck disable=SC2016
    local unsafe_paths=(
        '$(rm -rf /tmp/root-was-wiped)'
        '`touch /tmp/hacked`'
        '|cat /etc/passwd'
        ';echo dangerous'
        '&&echo injected'
        '||echo fallback'
    )

    for unsafe_path in "${unsafe_paths[@]}"; do
        run tool_file_size "{\"path\":\"${unsafe_path}\"}"
        assert_failure

        # Should only contain generic error message, not the malicious input
        assert_output --partial "file not accessible"
        refute_output --partial "dangerous"
        refute_output --partial "injected"
        refute_output --partial "fallback"
        refute_output --partial "rm -rf"
        refute_output --partial "hacked"
    done
}

@test "tool_file_size: handles non-existent file gracefully" {
    run tool_file_size "{\"path\":\"/nonexistent/path/file.txt\"}"
    assert_failure
}

@test "tool_file_size: handles invalid JSON input" {
    run tool_file_size "invalid json"
    assert_failure
}

@test "tool_file_size: handles missing path argument" {
    run tool_file_size "{}"
    assert_failure
}
