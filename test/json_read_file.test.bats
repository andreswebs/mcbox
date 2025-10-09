#!/usr/bin/env bats
# shellcheck shell=bats

load '../mcbox-core.bash'

setup() {
    test_dir="${BATS_TEST_TMPDIR}/json_files"
    mkdir -p "${test_dir}"
}

@test "json_read_file: should fail with no arguments" {
    run json_read_file
    [ "${status}" -eq 1 ]
}

@test "json_read_file: should fail with non-existent file" {
    run json_read_file "/non/existent/file.json"
    [ "${status}" -eq 1 ]
}

@test "json_read_file: should fail with unreadable file" {
    local json_file="${test_dir}/unreadable.json"
    echo '{"test": "value"}' >"${json_file}"
    chmod 000 "${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 1 ]

    # Clean up permissions for removal
    chmod 644 "${json_file}"
}

@test "json_read_file: should fail with directory instead of file" {
    local json_dir="${test_dir}/not_a_file"
    mkdir -p "${json_dir}"

    run json_read_file "${json_dir}"
    [ "${status}" -eq 1 ]
}

@test "json_read_file: should read valid simple JSON object" {
    local json_file="${test_dir}/simple.json"
    local json_content='{"name": "John", "age": 30}'
    local expected='{"name":"John","age":30}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should read valid JSON array" {
    local json_file="${test_dir}/array.json"
    local json_content='["item1", "item2", "item3"]'
    local expected='["item1","item2","item3"]'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should read complex nested JSON" {
    local json_file="${test_dir}/complex.json"
    local json_content='{
        "users": [
            {"name": "John", "age": 30, "active": true},
            {"name": "Jane", "age": 25, "active": false}
        ],
        "config": {
            "debug": true,
            "timeout": 5000,
            "endpoints": {
                "api": "https://api.example.com",
                "auth": "https://auth.example.com"
            }
        },
        "version": "1.2.3"
    }'
    local expected='{"users":[{"name":"John","age":30,"active":true},{"name":"Jane","age":25,"active":false}],"config":{"debug":true,"timeout":5000,"endpoints":{"api":"https://api.example.com","auth":"https://auth.example.com"}},"version":"1.2.3"}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should read empty JSON object" {
    local json_file="${test_dir}/empty.json"
    local json_content='{}'
    local expected='{}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should read empty JSON array" {
    local json_file="${test_dir}/empty_array.json"
    local json_content='[]'
    local expected='[]'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should handle JSON with special characters" {
    local json_file="${test_dir}/special_chars.json"
    local json_content='{"message": "Hello \"World\"!\nNew line and unicode: 🌟", "path": "/home/user/file.txt"}'
    local expected='{"message":"Hello \"World\"!\nNew line and unicode: 🌟","path":"/home/user/file.txt"}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should fail with invalid JSON syntax" {
    local json_file="${test_dir}/invalid.json"
    local json_content='{"name": "John", "age":}' # Missing value for age

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 1 ]
}

@test "json_read_file: should fail with malformed JSON" {
    local json_file="${test_dir}/malformed.json"
    local json_content='{"name": "John" "age": 30}' # Missing comma

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 1 ]
}

@test "json_read_file: should fail with empty file" {
    local json_file="${test_dir}/empty_file.json"

    touch "${json_file}" # Create empty file

    run json_read_file "${json_file}"
    [ "${status}" -eq 1 ]
}

@test "json_read_file: should handle JSON with null values" {
    local json_file="${test_dir}/with_nulls.json"
    local json_content='{"name": "John", "middle_name": null, "age": 30}'
    local expected='{"name":"John","middle_name":null,"age":30}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should handle JSON with boolean values" {
    local json_file="${test_dir}/with_booleans.json"
    local json_content='{"active": true, "deleted": false, "verified": true}'
    local expected='{"active":true,"deleted":false,"verified":true}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_read_file: should handle JSON with numeric values" {
    local json_file="${test_dir}/with_numbers.json"
    local json_content='{"integer": 42, "float": 3.14159, "negative": -10, "zero": 0}'
    local expected='{"integer":42,"float":3.14159,"negative":-10,"zero":0}'

    echo "${json_content}" >"${json_file}"

    run json_read_file "${json_file}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}
