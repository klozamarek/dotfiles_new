#!/bin/zsh
# +-----------------+
# | file management |
# +-----------------+
#-- file rename to my specific format{{{
renf () {
# Use fzf to choose the file to rename
filename=$(find . -maxdepth 1 -type f -printf '%f\n' | fzf --preview 'echo {}' --prompt='Choose a file to rename: ')

# Get the chosen REF/LST option from the user
echo "1) REF  2) LST  3) NOTE  4) READ ?"
read -r ref_or_lst
case $ref_or_lst in
    1) ref_or_lst="REF" ;;
    2) ref_or_lst="LST" ;;
    3) ref_or_lst="NOTE" ;;
    4) ref_or_lst="READ" ;;
    *) echo "Invalid option. Please choose 1, 2, 3, or 4." && exit 1 ;;
esac

# Get the chosen HME/WRK option from the user
echo "1) HME  2) WRK ?"
read -r hme_or_wrk
case $hme_or_wrk in
    1) hme_or_wrk="HME" ;;
    2) hme_or_wrk="WRK" ;;
    *) echo "Invalid option. Please choose 1 or 2." && exit 1 ;;
esac

# Get the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

# Ask the user if they want to use the original filename or enter a new filename
echo "Use original filename ($filename)? [Y/n]"
read -r use_original_filename

if [[ $use_original_filename =~ ^[Nn]$ ]]; then
    # If the user doesn't want to use the original filename, ask them to enter a new filename
    echo "Enter a new filename:"
    read -r new_filename
else
    # If the user wants to use the original filename, replace all whitespace characters in the filename with underscores
    new_filename="${filename// /_}"
fi

# Get the extension from the original filename
extension="${filename##*.}"

# Prepend the date, REF/LST option, HME/WRK option, and modified filename to the new filename
new_filename="${current_date}_${ref_or_lst}-${hme_or_wrk}_${new_filename%.*}.${extension}"

# Rename the file
mv "$filename" "$new_filename"

echo "File renamed to $new_filename."
}
#--------------------------------------------}}}
#-- replace whitespaces with underscores and make lowercase all filenames in cwd{{{
lowscore () {
for file in *; do 
    mv "$file" "${file// /_}" >/dev/null 2>&1 
    mv "${file// /_}" "$(echo ${file// /_} | tr '[:upper:]' '[:lower:]')" >/dev/null 2>&1; 
done
}
#--------------------------------------------
# Compress a file
compress() {
    tar cvzf $1.tar.gzd $1
}
#--------------------------------------------
# mail file using nnn
mailf() {
    if [[ $1 == *@* ]]; then
        mail -a $(nnn -p -) $1
    else
        echo "cannot send :( - please provide email adress"
    fi
}
#--------------------------------------------}}}
#-- Open pdf with Zathura{{{
fpdf() {
    result=$(find -type f -name '*.pdf' | fzf --bind "ctrl-r:reload(find -type f -name '*.pdf')" --preview "pdftotext {} - | less")
    [ -n "$result" ] && nohup zathura "$result" &> /dev/null & disown
}
#--------------------------------------------}}}
#-- Internal function to extract any file{{{
_ex() {
    case $1 in
        *.tar.bz2)  tar xjf $1      ;;
        *.tar.gz)   tar xzf $1      ;;
        *.bz2)      bunzip2 $1      ;;
        *.gz)       gunzip $1       ;;
        *.tar)      tar xf $1       ;;
        *.tbz2)     tar xjf $1      ;;
        *.tgz)      tar xzf $1      ;;
        *.zip)      unzip $1        ;;
        *.7z)       7z x $1         ;; # require p7zip
        *.rar)      7z x $1         ;; # require p7zip
        *.iso)      7z x $1         ;; # require p7zip
        *.Z)        uncompress $1   ;;
        *)          echo "'$1' cannot be extracted" ;;
    esac
}
#--------------------------------------------}}}
#-- configure nnn cd on quit{{{
n ()
{
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    }
}
#--------------------------------------------------}}}
# +--------+
# | backup |
# +--------+
# {{{
backup() {
    "$HOME/.bash/scripts/backup/backup.sh" "-x" "$@" "$HOME/.bash/scripts/backup/dir.csv"
}
# }}}
# +------+
# | tmux |
# +------+
# {{{
ftmuxp() {
    if [[ -n $TMUX ]]; then
        return
    fi

    # get the IDs
    ID="$(ls $XDG_CONFIG_HOME/tmuxp | sed -e 's/\.yml$//')"
    if [[ -z "$ID" ]]; then
        tmux new-session
    fi

    create_new_session="Create New Session"

    ID="${create_new_session}\n$ID"
    ID="$(echo $ID | fzf | cut -d: -f1)"

    if [[ "$ID" = "${create_new_session}" ]]; then
        tmux new-session
    elif [[ -n "$ID" ]]; then
        # Rename the current urxvt tab to session name
        printf '\033]777;tabbedx;set_tab_name;%s\007' "$ID"
        tmuxp load "$ID"
    fi
}
#--------------------------------------------}}}
#-- Run man pages in nvim{{{
vman() {
    nvim -c "SuperMan $*"

    if [ "$?" != "0"]; then
        echo "No manual entry for $*"
    fi
}
#--------------------------------------------}}}
#-- Run scratchpad {{{
scratchpad() {
    "$DOTFILES/zsh/scratchpad.sh"
}
#--------------------------------------------}}}
#-- Run script preventing shell run ranger run shell{{{
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}
# }}}
# +----------------+
# | sys management |
# +----------------+
#-- Run script to update Arch and others{{{
updatesys() {
    sh $HOME/update.sh
}
#--------------------------------------------}}}
#-- history statistics{{{
historystat() {
    history 0 | awk '{ if ($2 == "sudo") {print $3} else {print $2} }' | awk -v "FS=|" '{print $1}' | sort | uniq -c | sort -r -n | head -15
}
#--------------------------------------------}}}
#-- check if the package is installed{{{
# usage `_isInstalled "package_name"`
# output 1 not installed; 0 already installed
_isInstalled() {
    package="$1";
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ; then
        echo "installed"; #'0' means 'true' in zsh
        return; #true
    fi;
    echo "NOT installed"; #'1' means 'false' in zsh
    return; #false
}
#--------------------------------------------}}}
#-- install <pkg>{{{
_install() {
    package="$1";

    # If the package IS installed:
    if [[ $(_isInstalled "${package}") == 0 ]]; then
        echo "${package} is already installed.";
        return;
    fi;

    # If the package is NOT installed:
    if [[ $(_isInstalled "${package}") == 1 ]]; then
        sudo pacman -S "${package}";
    fi;
}
#--------------------------------------------}}}
#-- installMany <pkg1> <pkg2> ...{{{
# Works the same as `_install` above,
# but you can pass more than one package to this one.
_installMany() {
    # The packages that are not installed will be added to this array.
    toInstall=();

    for pkg; do
        # If the package IS installed, skip it.
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed.";
            continue;
        fi;

        #Otherwise, add it to the list of packages to install.
        toInstall+=("${pkg}");
    done;

    # If no packages were added to the "${toInstall[@]}" array,
    #     don't do anything and stop this function.
    if [[ "${toInstall[@]}" == "" ]] ; then
        echo "All packages are already installed.";
        return;
    fi;

    # Otherwise, install all the packages that have been added to the "${toInstall[@]}" array.
    printf "Packages not installed:\n%s\n" "${toInstall[@]}";
    sudo pacman -S "${toInstall[@]}";
}
#--------------------------------------------}}}
#-- list all user installed software with description{{{

list_apps() {

    for line in "$(pacman -Qqe)"; do pacman -Qi $(echo "$line") ; done | perl -pe 's/ +/ /gm' | perl -pe 's/^(Groups +: )(.*)/$1($2)/gm' | perl -0777 -pe 's/^Name : (.*)\nVersion :(.*)\nDescription : ((?!None).*)?(?:.|\n)*?Groups :((?! \(None\)$)( )?.*)?(?:.|\n(?!Name))+/$1$2$4\n    $3/gm' | grep -A1 --color -P "^[^\s]+"
}
# }}}
# +-------+
# | music |
# +-------+
#-- Run function to convert .ape -> .flac{{{
# function to convert .ape file to .flac file
# run from the relevant directory
ape2flac() {
find . -name "*.ape" -exec sh -c 'exec ffmpeg -i "$1" "${1%.ape}.flac"' _ {} \;
}
#--------------------------------------------}}}
#-- Run function to split flac files from cue sheet{{{
# function to split individual flac files from cue sheet
# output is <nr>-<SongName>
# run from relevant directory
cue2flac() {
find . -name "*.cue" -exec sh -c 'exec shnsplit -f "$1" -o flac -t "%n-%t" "${1%.cue}.flac"' _ {} \;
}
#--------------------------------------------}}}
#-- Run function to tag flac files from cue sheet{{{
# function to tag flac files from cue sheet
# remove the unsplit flac file FIRST!
tag2flac() {
    echo "please remove the unsplit (large) .flac file FIRST!!"
    find . -name "*.cue" -execdir sh -c 'exec cuetag.sh "$1" *.flac' _ {} \;
} 
#--------------------------------------------}}}
#-- Run function to convert .wav -> flac{{{
# run from relevant directory
wav2flac() {
      find . -name "*.wav" -exec sh -c 'exec ffmpeg -i "$1" "${1%.wav}.flac"' _ {} \;
}
#--------------------------------------------}}}

#-- zsh completion{{{
# Display all autocompleted command in zsh.
# First column: command name Second column: completion function
zshcomp() {
    for command completion in ${(kv)_comps:#-*(-|-,*)}
    do
        printf "%-32s %s\n" $command $completion
    done | sort
}
#--------------------------------------------}}}
#-- ripgrep-all and fzf intergation as per t.ly/fCsVn{{{
rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	xdg-open "$file"
}
#--------------------------------------------}}}
#-- Find in File using ripgrep{{{
fif() {
  if [ ! "$#" -gt 0 ]; then return 1; fi
  rg --files-with-matches --no-messages "$1" \
      | fzf --preview "highlight -O ansi -l {} 2> /dev/null \
      | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
      || rg --ignore-case --pretty --context 10 '$1' {}"
}
#--------------------------------------------}}}
#-- Find in file using ripgrep-all{{{
fifa() {
    if [ ! "$#" -gt 0 ]; then return 1; fi
    local file
    file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$*" \
        | fzf-tmux -p +m --preview="rga --ignore-case --pretty --context 10 '"$*"' {}")" \
        && print -z "./$file" || return 1;
}
#--------------------------------------------}}}
#-- to show in nnn mime-type of files (nnn related){{{
# posible types: audio, video, image, text, application, font
# for full list google "common mime types"
# to show video files, run: list video
list ()                                                                                                    
{
    find . -maxdepth 1 | file -if- | grep "$1" | awk -F: '{printf "%s\0", $1}' | nnn
    # fd -d 1 | file -if- | grep "$1" | awk -F: '{printf "%s\0", $1}' | nnn
}
# }}}
# +---------+
# | imaging |
# +---------+
#-- Take a screenshot{{{
screenshot () {
    local DIR="$SCREENSHOT"
    local DATE="$(date +%Y%m%d-%H%M%S)"
    local NAME="${DIR}/screenshot-${DATE}.png"

    # Check if the dir to store the screenshots exists, else create it:
    if [ ! -d "${DIR}" ]; then mkdir -p "${DIR}"; fi

    # Screenshot a selected window
    if [ "$1" = "win" ]; then import -format png -quality 100 "${NAME}"; fi

    # Screenshot the entire screen
    if [ "$1" = "scr" ]; then import -format png -quality 100 -window root "${NAME}"; fi

    # Screenshot a selected area
    if [ "$1" = "area" ]; then import -format png -quality 100 "${NAME}"; fi

    if [[ $1 =~ "^[0-9].*x[0-9].*$" ]]; then import -format png -quality 100 -resize $1 "${NAME}"; fi

    if [[ $1 =~ "^[0-9]+$" ]]; then import -format png -quality 100 -resize $1 "${NAME}" ; fi

    if [[ $# = 0 ]]; then
        # Display a warning if no area defined
        echo "No screenshot area has been specified. Please choose between: win, scr, area. Screenshot not taken."
    fi
}
# }}}

#-- notetaking function {{{
# usage : an <filename> "text"
# when prompted choose tags separated by spaces and hit ENTER
# if you choose to create new tag enter new tag_name
# the "text" snippet is prepended by timestatmp yyyy-mm-dd hh:mm and chosen tag(s)
# if <filename> is not provided the "text" will be appended to $HOME/Documents/mydirtynotes.txt by default
# and at the same time to ssh server to $HOME/Documents/mydirtynotes.txt
# if <filename> is provided the files (local and on the ssh server) will be created (if do not not exist)
# default path is $HOME/Documents/<filename>

an() {
  local filename text

  if (( $# == 1 )); then
    text=$1
    filename="mydirtynotes.txt"
  elif (( $# == 2 )); then
    filename=$1
    text=$2
  else
    echo "Invalid number of arguments. Please provide one or two arguments."
    return 1
  fi
  
  local timestamp=$(date +"%Y-%m-%d %H:%M")

  # Get the chosen tags from the user
  echo "Pick one or more tags separated by space: 1)#LINUX 2)#READ 3)#NOTE 4)#TODO 5)#IDEA 6)#VARIA 7)#NVIM 8)#HOME 9)#BUY 0)Create new tag"
  read -r tag_numbers

  # create a variable to hold all tags
  local tags=""

  # convert the tag numbers into an array
  tag_numbers=(${(s/ /)tag_numbers})

  # loop through all tag numbers
  for number in "${tag_numbers[@]}"; do
    case $number in
      1) tags+="#LINUX " ;;
      2) tags+="#READ " ;;
      3) tags+="#NOTE " ;;
      4) tags+="#TODO " ;;
      5) tags+="#IDEA " ;;
      6) tags+="#VARIA " ;;
      7) tags+="#NVIM " ;;
      8) tags+="#HOME " ;;
      9) tags+="#BUY " ;;
      0) 
        echo "Enter new tag:"
        read -r new_tag
        tags+="#$new_tag"
        ;;
      *) echo "Invalid option. Please choose 0-9." && return 1 ;;
    esac
  done

# Remove trailing whitespaces from tags
  tags=$(echo "$tags" | sed 's/  *$//g')

  # Remove line breaks from the text
  local text_no_newlines=$(echo "$text" | tr '\n' ' ')
  local note="$timestamp $tags $text_no_newlines"

# create the file if it does not exist and append the note to the local file
  touch "$HOME/Documents/$filename" && echo "$note" >> "$HOME/Documents/$filename"

  # create the file if it does not exist and append the note to the file on the ssh server
  ssh ssserpent@antix "touch \"$HOME/Documents/$filename\" && echo \"$note\" >> \"$HOME/Documents/$filename\""
}
#---------------------------------------------------------------}}}
