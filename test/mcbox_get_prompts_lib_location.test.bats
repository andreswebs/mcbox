#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {
    CANONICAL_TMPDIR=$(realpath "${BATS_TEST_TMPDIR}")
}

teardown() {
    unset MCBOX_PROMPTS_LIB_FILE
    unset MCBOX_CONFIG_HOME
}

@test "mcbox_get_prompts_lib_location: returns default path under config home" {
    export MCBOX_CONFIG_HOME="${BATS_TEST_TMPDIR}/config"
    run mcbox_get_prompts_lib_location
    assert_success
    assert_output "${CANONICAL_TMPDIR}/config/prompts.bash"
}

@test "mcbox_get_prompts_lib_location: returns MCBOX_PROMPTS_LIB_FILE when set" {
    export MCBOX_PROMPTS_LIB_FILE="${BATS_TEST_TMPDIR}/custom-prompts.bash"
    run mcbox_get_prompts_lib_location
    assert_success
    assert_output "${CANONICAL_TMPDIR}/custom-prompts.bash"
}
