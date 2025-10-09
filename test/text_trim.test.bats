#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "text_trim with arguments: basic whitespace trimming" {
    run text_trim "   hello world   "
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: leading whitespace only" {
    run text_trim "   hello world"
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: trailing whitespace only" {
    run text_trim "hello world   "
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: no whitespace" {
    run text_trim "hello world"
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: empty string" {
    run text_trim ""
    assert_success
    assert_output ""
}

@test "text_trim with arguments: only whitespace" {
    run text_trim "   "
    assert_success
    assert_output ""
}

@test "text_trim with arguments: tabs and spaces" {
    run text_trim $'\t  hello world  \t'
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: newlines" {
    run text_trim $'\n\n  hello world  \n\n'
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: mixed whitespace" {
    run text_trim $' \t\n  hello world  \n\t '
    assert_success
    assert_output "hello world"
}

@test "text_trim with arguments: preserves internal whitespace" {
    run text_trim "  hello   world  "
    assert_success
    assert_output "hello   world"
}

@test "text_trim with arguments: multiple arguments concatenated" {
    run text_trim "  hello  " "  world  "
    assert_success
    assert_output "hello     world"
}

@test "text_trim with piped input: basic whitespace trimming" {
    run bats_pipe echo "   hello world   " \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: leading whitespace only" {
    run bats_pipe echo "   hello world" \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: trailing whitespace only" {
    run bats_pipe echo "hello world   " \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: no whitespace" {
    run bats_pipe echo "hello world" \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: empty string" {
    run bats_pipe echo "" \| text_trim
    assert_success
    assert_output ""
}

@test "text_trim with piped input: only whitespace" {
    run bats_pipe echo "   " \| text_trim
    assert_success
    assert_output ""
}

@test "text_trim with piped input: tabs and spaces" {
    run bats_pipe printf "\t  hello world  \t" \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: newlines at ends" {
    run bats_pipe printf "\n\n  hello world  \n\n" \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: mixed whitespace" {
    run bats_pipe printf " \t\n  hello world  \n\t " \| text_trim
    assert_success
    assert_output "hello world"
}

@test "text_trim with piped input: preserves internal whitespace" {
    run bats_pipe echo "  hello   world  " \| text_trim
    assert_success
    assert_output "hello   world"
}

@test "text_trim with piped input: multiline content" {
    run bats_pipe printf "  \nhello\nworld\n  " \| text_trim
    assert_success
    assert_output $'hello\nworld'
}

@test "text_trim with piped input: preserves internal newlines" {
    run bats_pipe printf "  hello\nworld  " \| text_trim
    assert_success
    assert_output $'hello\nworld'
}

@test "text_trim with no input (stdin empty)" {
    run bats_pipe echo -n "" \| text_trim
    assert_success
    assert_output ""
}
