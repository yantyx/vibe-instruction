#!/bin/bash

# Script to fix line endings and remove trailing whitespace
# Usage: ./fix-line-endings.sh <file1> [file2 ...]

set -euo pipefail

# Functions

process_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		# Remove trailing whitespace (spaces/tabs) and carriage returns
		sed -i 's/[ \t\r]*$//' "$file"
	else
		echo "Warning: '$file' is not a regular file. Skipping." >&2
	fi
}

main() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: $0 <file1> [file2 ...]" >&2
		exit 1
	fi

	for file in "$@"; do
		process_file "$file"
	done
}

main "$@"
