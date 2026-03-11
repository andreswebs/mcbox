#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {
    export MCBOX_SERVER_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.server.json"
    export MCBOX_TOOLS_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.tools.json"
    export MCBOX_TOOLS_LIB_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.tools.bash"
    export MCBOX_PROMPTS_CONFIG_FILE="${BATS_TEST_TMPDIR}/prompts.json"
    export MCBOX_PROMPTS_LIB_FILE="${BATS_TEST_TMPDIR}/prompts.bash"
}

teardown() {
    unset MCBOX_SERVER_CONFIG_FILE
    unset MCBOX_TOOLS_CONFIG_FILE
    unset MCBOX_TOOLS_LIB_FILE
    unset MCBOX_PROMPTS_CONFIG_FILE
    unset MCBOX_PROMPTS_LIB_FILE
    unset MCBOX_PROMPTS_CONFIG
}

@test "mcbox_load_config: sets MCBOX_PROMPTS_CONFIG when prompts.json is valid" {
    echo '{"prompts":[]}' >"${MCBOX_PROMPTS_CONFIG_FILE}"
    touch "${MCBOX_PROMPTS_LIB_FILE}"

    run mcbox_load_config
    assert_success

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo \"\${MCBOX_PROMPTS_CONFIG}\"
    "
    assert_success
    assert_output --partial '"prompts"'
}

@test "mcbox_load_config: uses empty fallback when prompts.json is missing" {
    # No prompts.json created - file does not exist
    touch "${MCBOX_PROMPTS_LIB_FILE}"

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo \"\${MCBOX_PROMPTS_CONFIG}\"
    "
    assert_success
    assert_output --partial '{"prompts":[]}'
}

@test "mcbox_load_config: uses empty fallback when prompts.json has invalid JSON" {
    echo "{ not valid json }" >"${MCBOX_PROMPTS_CONFIG_FILE}"
    touch "${MCBOX_PROMPTS_LIB_FILE}"

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo \"\${MCBOX_PROMPTS_CONFIG}\"
    "
    assert_success
    assert_output --partial '{"prompts":[]}'
}

@test "mcbox_load_config: uses empty fallback when prompts.json fails schema validation" {
    echo '{"not_prompts": []}' >"${MCBOX_PROMPTS_CONFIG_FILE}"
    touch "${MCBOX_PROMPTS_LIB_FILE}"

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo \"\${MCBOX_PROMPTS_CONFIG}\"
    "
    assert_success
    assert_output --partial '{"prompts":[]}'
}

@test "mcbox_load_config: continues when prompts.bash is missing" {
    echo '{"prompts":[]}' >"${MCBOX_PROMPTS_CONFIG_FILE}"
    # No prompts.bash created

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo ok
    "
    assert_success
    assert_output --partial "ok"
}

@test "mcbox_load_config: continues when prompts.bash fails to source" {
    echo '{"prompts":[]}' >"${MCBOX_PROMPTS_CONFIG_FILE}"
    printf '#!/usr/bin/env bash\nreturn 1\n' >"${MCBOX_PROMPTS_LIB_FILE}"

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo ok
    "
    assert_success
    assert_output --partial "ok"
}

@test "mcbox_load_config: sources prompts.bash when it exists and is valid" {
    echo '{"prompts":[]}' >"${MCBOX_PROMPTS_CONFIG_FILE}"
    printf '#!/usr/bin/env bash\nMCBOX_TEST_PROMPTS_SOURCED=yes\n' >"${MCBOX_PROMPTS_LIB_FILE}"

    run bash -c "
        source '${BATS_TEST_DIRNAME}/../mcbox-core.bash'
        export MCBOX_SERVER_CONFIG_FILE='${MCBOX_SERVER_CONFIG_FILE}'
        export MCBOX_TOOLS_CONFIG_FILE='${MCBOX_TOOLS_CONFIG_FILE}'
        export MCBOX_TOOLS_LIB_FILE='${MCBOX_TOOLS_LIB_FILE}'
        export MCBOX_PROMPTS_CONFIG_FILE='${MCBOX_PROMPTS_CONFIG_FILE}'
        export MCBOX_PROMPTS_LIB_FILE='${MCBOX_PROMPTS_LIB_FILE}'
        mcbox_load_config
        echo \"\${MCBOX_TEST_PROMPTS_SOURCED:-not_sourced}\"
    "
    assert_success
    assert_output --partial "yes"
}
