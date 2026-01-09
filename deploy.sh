#!/bin/bash

# ============================================================================
# Deploy Copilot tools and instructions to a target project's .github directory.
# Supports local paths and remote paths (user@host:/path) via rsync.
# ============================================================================

set -euo pipefail

# Constants
readonly SOURCE_DIRS=("agents" "instructions" "scripts" "skills")
readonly SCRIPT_NAME="$(basename "$0")"
readonly PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Functions
usage() {
	echo "Usage: $SCRIPT_NAME [OPTIONS] <target_project_path>"
	echo
	echo "Options:"
	echo "  -h, --help    Show this help message"
	echo
	echo "Example: $SCRIPT_NAME /path/to/project"
	echo "Example: $SCRIPT_NAME user@hostname:/path/to/project"
	exit "${1:-1}"
}

check_dependencies() {
	if ! command -v rsync >/dev/null 2>&1; then
		echo "Error: rsync is not installed." >&2
		exit 1
	fi
}

main() {
	check_dependencies

	if [[ $# -ne 1 ]]; then
		usage
	fi

	local target="${1%/}"
	local github_target="$target/.github"

	# Identify existing source folders
	local existing_dirs=()
	for dir in "${SOURCE_DIRS[@]}"; do
		if [[ -d "$PROJECT_ROOT/$dir" ]]; then
			existing_dirs+=("$PROJECT_ROOT/$dir")
		fi
	done

	if [[ ${#existing_dirs[@]} -eq 0 ]]; then
		echo "Error: No source directories found in $PROJECT_ROOT to deploy." >&2
		exit 1
	fi

	echo "Deploying tools to $github_target..."

	if [[ "$target" =~ : ]]; then
		# Remote deployment: Use --rsync-path to mkdir and sync in ONE SSH session
		rsync -avz --quiet --rsync-path="mkdir -p '${target#*:}/.github' && rsync" "${existing_dirs[@]}" "$github_target/"
	else
		# Local deployment
		mkdir -p "$github_target"
		rsync -av --quiet "${existing_dirs[@]}" "$github_target/"
	fi

	echo "Deployment complete."
}

# Parse options
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage 0
fi

main "$@"
