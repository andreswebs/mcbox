#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "mcp_handle_notification: should handle 'notifications/initialized' method" {
    run mcp_handle_notification "notifications/initialized"
    assert_success
    assert_output --partial "initialized"
}

@test "mcp_handle_notification: should fail for unknown notification type" {
    run mcp_handle_notification "notifications/unknown"
    assert_failure
}

@test "mcp_handle_notification: should fail for non-notification method" {
    run mcp_handle_notification "tools/list"
    assert_failure
}

@test "mcp_handle_notification: should fail for empty method" {
    run mcp_handle_notification ""
    assert_failure
}

@test "mcp_handle_notification: should rfailfor malformed notification method" {
    run mcp_handle_notification "invalid-method"
    assert_failure
}
