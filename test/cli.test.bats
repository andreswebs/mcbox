#!/usr/bin/env bats

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'
load 'bats-helpers/bats-file/load'

setup_file() {
    # shellcheck disable=SC2329
    function mcbox() {
        MCBOX_CORE_LIB_FILE="${BATS_TEST_DIRNAME}/../mcbox-core.bash" "${BATS_TEST_DIRNAME}/../mcbox-server.bash" "${@}"
    }

    export -f mcbox

    export MCBOX_LOG_LEVEL="debug"
}

setup() {
    if [[ "${BATS_TEST_DESCRIPTION}" == "cli: mcbox --version" ]]; then
        local version_json
        version_json='{
          "Version": "test_version",
          "Commit": "test_commit",
          "BuildDate": "test_build_date"
        }'

        MCBOX_DATA_HOME="${BATS_TEST_TMPDIR}/mcbox-test-data"
        mkdir -p "${MCBOX_DATA_HOME}"
        echo "${version_json}" | jq  --compact-output --monochrome-output '.' >"${MCBOX_DATA_HOME}/version.json"

        export MCBOX_DATA_HOME
    fi

    if [[ "${BATS_TEST_DESCRIPTION}" == "cli: mcbox init-config" ]] || \
       [[ "${BATS_TEST_DESCRIPTION}" == "cli: mcbox init-config --overwrite" ]]; then
        MCBOX_DATA_HOME=$(realpath -q "${BATS_TEST_DIRNAME}/..")
        MCBOX_CONFIG_HOME="${BATS_TEST_TMPDIR}/mcbox-test-config"

        export MCBOX_DATA_HOME MCBOX_CONFIG_HOME
    fi

    if [[ "${BATS_TEST_DESCRIPTION}" == "cli: mcbox init-config --overwrite" ]]; then
        mkdir -p "${MCBOX_CONFIG_HOME}"
        echo "{}" > "${MCBOX_CONFIG_HOME}/server.json"
        echo "{}" > "${MCBOX_CONFIG_HOME}/tools.json"
        echo "{}" > "${MCBOX_CONFIG_HOME}/tools.bash"
    fi

}

@test "cli: mcbox --not-defined" {
    run mcbox --not-defined
    assert_failure
    assert_output --partial "invalid option"
}

@test "cli: mcbox --help" {
    run mcbox --help
    assert_success
    assert_output --partial "Usage:"
}

@test "cli: mcbox --version" {
    run mcbox --version
    assert_success
    assert_output --partial "mcbox test_version Commit: test_commit BuildDate: test_build_date"
}

@test "cli: mcbox init-config" {
    run mcbox init-config
    assert_success
    assert_dir_exists "${MCBOX_CONFIG_HOME}"
    assert_file_exists "${MCBOX_CONFIG_HOME}/server.json"
    assert_file_exists "${MCBOX_CONFIG_HOME}/tools.json"
    assert_file_exists "${MCBOX_CONFIG_HOME}/tools.bash"
}

@test "cli: mcbox init-config --overwrite" {
    local server_mtime_before
    local tools_json_mtime_before
    local tools_bash_mtime_before
    server_mtime_before=$(stat -f "%m" "${MCBOX_CONFIG_HOME}/server.json")
    tools_json_mtime_before=$(stat -f "%m" "${MCBOX_CONFIG_HOME}/tools.json")
    tools_bash_mtime_before=$(stat -f "%m" "${MCBOX_CONFIG_HOME}/tools.bash")

    # Sleep briefly to ensure different timestamps
    sleep 1

    run mcbox init-config --overwrite

    assert_success
    assert_dir_exists "${MCBOX_CONFIG_HOME}"
    assert_file_exists "${MCBOX_CONFIG_HOME}/server.json"
    assert_file_exists "${MCBOX_CONFIG_HOME}/tools.json"
    assert_file_exists "${MCBOX_CONFIG_HOME}/tools.bash"

    local server_mtime_after
    local tools_json_mtime_after
    local tools_bash_mtime_after
    server_mtime_after=$(stat -f "%m" "${MCBOX_CONFIG_HOME}/server.json")
    tools_json_mtime_after=$(stat -f "%m" "${MCBOX_CONFIG_HOME}/tools.json")
    tools_bash_mtime_after=$(stat -f "%m" "${MCBOX_CONFIG_HOME}/tools.bash")

    [[ "${server_mtime_after}" -gt "${server_mtime_before}" ]] || fail
    [[ "${tools_json_mtime_after}" -gt "${tools_json_mtime_before}" ]] || fail
    [[ "${tools_bash_mtime_after}" -gt "${tools_bash_mtime_before}" ]] || fail

    refute_line --partial "{}" < "${MCBOX_CONFIG_HOME}/server.json"
    refute_line --partial "{}" < "${MCBOX_CONFIG_HOME}/tools.json"
    refute_line --partial "{}" < "${MCBOX_CONFIG_HOME}/tools.bash"
}
