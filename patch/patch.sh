#!/bin/sh
# apply/reverse all patches easily,
# to keep the stacking order of the patches.

## introduces make warnings!
#./patch/4.9/dmenu-xresources-4.9.diff

## original apply patch order
read -d '' ORDER <<- EOF
./patch/5.0/dmenu-fix_make_warning_INTERSECT-5.0.diff
./patch/5.0/dmenu-fix_color_fonts-5.0.diff
./patch/5.0/dmenu-password_4.9FIX-5.0.diff
./patch/4.9/dmenu-xresources-4.9.diff
EOF

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -h, --help      Display help
    -l, --list      Print list of patches in default order
    -R, --reverse   Reverse list of patches and apply 'patch --reverse' option:
                    Assume patches were created with old and new files swapped.
    --dry-run       Print the results of applying the patches without actually
                    changing any files.
                    ${red}(each patch file independently, not a cascade of changes)${end}
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=hlR
    LONG=help,list,reverse,dry-run
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -l|--list)
            echo "patches in default apply patch order:"
            echo "${mag}$ORDER${end}"
            exit 0
            ;;
        -R|--reverse)
            R=(--reverse)
            ORDER=$(echo "$ORDER" | tac)
            ;;
        --dry-run)
            dry=(--dry-run)
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done
}

get_opt "$@"

if [[ $R ]]; then # if variable defined
    Q="Reverse ALL patches? [Y/n] "
else
    Q="Apply ALL patches? [Y/n] "
fi

read -p "$Q" -n 1 -r
echo "" # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    # handle exits from shell or function but don't exit interactive shell
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

cd "$(git rev-parse --show-toplevel)" # cd to root git dir
# read line by line
while IFS= read -r line; do
    printf "%s%s\n" "${blu}$(dirname $line)/${end}" \
                    "${cyn}$(basename $line)${end}"
    patch -f "${R[@]}" "${dry[@]}" < "${line[@]}"
done <<< "$ORDER"

echo "${grn}THE END OF THE SCRIPT REACHED${end}"
