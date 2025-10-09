#!/usr/bin/env bash

function tool_file_size() {
    local arguments="${1}"
    local file_path
    file_path=$(echo "${arguments}" | jq --raw-output '.path')

    if ! is_readable_file "${file_path}"; then
        log_error "file not accessible"
        return 1
    fi

    local size
    if ! size=$(wc -c < "${file_path}" 2>/dev/null); then
        log_error "failed to get file size"
        return 1
    fi

    jq --compact-output \
        --null-input \
        --arg path "${file_path}" \
        --argjson size "${size}" \
        '{"path": $path, "size": $size}'
}

export -f tool_file_size
