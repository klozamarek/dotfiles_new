#!/usr/bin/env bash

set -uo pipefail

function output-help()
{
    echo "Usage :  $0 [options] [--]

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -d|dry-run    Run rsync with --dry-run for test
    -x|delete     Run rsync with --delete for mirroring
    -s|size-only  Run rsync with --size-only (no comparison with timestamps)"
}

function run() {
    local rsync_opts=(-avzu)
    local excludes=()

    __ScriptVersion="1.6"

    while getopts ":hvdxs" opt; do
        case $opt in
            h|help     )  output-help; exit 0 ;;
            v|version  )  echo "$0 -- Version $__ScriptVersion"; exit 0 ;;
            d|dry-run  )  rsync_opts+=(--dry-run); ;;
            x|delete   )  rsync_opts+=(--delete); ;;
            s|size-only)  rsync_opts+=(--size-only); ;;
            * ) echo -e "\n  Option does not exist : $OPTARG\n"
                output-help; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    [ "$#" -eq 0 ] && echo "You need to give a file as last argument" && exit 1

    local file="$1"

    # Sprawdzenie, czy plik istnieje
    if [[ ! -f "$file" ]]; then
        echo "File $file does not exist!"
        exit 1
    fi

    # Procesowanie pliku wejściowego
    while read -r line; do
        if [[ "$line" =~ ^exclude: ]]; then
            exclude_dir="${line#exclude:}"
            excludes+=("--exclude=${exclude_dir}")
        elif [[ -n "$line" && "$line" != "#"* ]]; then
            # Przetwarzanie par źródło/destynacja
            src="$(eval echo -e "${line%,*}")"
            dest="$(eval echo -e "${line#*,}")"

            echo "Copying $src to $dest from file $file"
            if [[ ! -d "$src" ]]; then
                echo "The directory $src does not exist -- NO BACKUP CREATED"
                continue
            fi

            # Synchronizacja za pomocą rsync
            rsync "${rsync_opts[@]}" "${excludes[@]}" "${src}/" "$dest" 2>> /tmp/errors

            # Usuwanie katalogów wykluczonych tylko z backupu
            for exclude in "${excludes[@]}"; do
                exclude_path="${exclude#--exclude=}"

                if [[ "$dest" =~ : ]]; then
                    # Zdalne usuwanie przez ssh
                    remote_host="${dest%%:*}"
                    remote_path="${dest#*:}/$exclude_path"
                    echo "Removing excluded directory from remote backup: $remote_path"
                    ssh "$remote_host" "rm -rf \"$remote_path\"" && \
                    echo "Removed: $remote_path" || \
                    echo "Failed to remove: $remote_path"
                else
                    # Lokalna ścieżka
                    full_exclude_path="$dest/$exclude_path"
                    echo "Removing excluded directory from local backup: $full_exclude_path"
                    if [[ -d "$full_exclude_path" ]]; then
                        rm -rf "$full_exclude_path"
                        echo "Removed: $full_exclude_path"
                    else
                        echo "Directory not found: $full_exclude_path"
                    fi
                fi
            done
        fi
    done < "$file"

    printf "ERRORS: \n"
    cat /tmp/errors || echo "No errors"
}

run "$@"

