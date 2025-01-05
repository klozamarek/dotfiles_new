#!/bin/zsh
#-- renf() file rename to my specific format --{{{
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
#}}}
# -- lowscore() replace whitespaces with underscores and make lowercase all filenames in cwd --{{{
lowscore () {
for file in *; do 
    mv "$file" "${file// /_}" >/dev/null 2>&1 
    mv "${file// /_}" "$(echo ${file// /_} | tr '[:upper:]' '[:lower:]')" >/dev/null 2>&1; 
done
}
#}}}
# -- compress() Compress a file --{{{
compress() {
    tar cvzf $1.tar.gzd $1
}
#}}}
# -- mailf() mail file using nnn --{{{
mailf() {
    if [[ $1 == *@* ]]; then
        mail -a $(nnn -p -) $1
    else
        echo "cannot send :( - please provide email adress"
    fi
}
#}}}
#-- fpdf() Open pdf with Zathura --{{{
fpdf() {
    result=$(find -type f -name '*.pdf' | fzf --bind "ctrl-r:reload(find -type f -name '*.pdf')" --preview "pdftotext {} - | less")
    [ -n "$result" ] && nohup zathura "$result" &> /dev/null & disown
}
#}}}
#-- _ex() Internal function to extract any file --{{{
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
#}}}
# -- n() configure nnn cd on quit --{{{
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
#}}}
# -- backup() Backup of chosen files/dirs --{{{
backup() {
    "$HOME/.bash/scripts/backup/backup.sh" "-x" "$@" "$HOME/.bash/scripts/backup/dir.csv"
}
#}}}
# -- ftmuxp() --{{{
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
#}}}
# -- vman() Run man pages in nvim --{{{
vman() {
    nvim -c "SuperMan $*"

    if [ "$?" != "0"]; then
        echo "No manual entry for $*"
    fi
}
#}}}
# -- scratchpad() Run scratchpad -DEPRECATED!!! --{{{
scratchpad() {
    "$DOTFILES/zsh/scratchpad.sh"
}
#}}}
#-- ranger() Run script preventing shell run ranger run shell --{{{
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}
#}}}
# -- updatesys() Run script to update Arch and others --{{{
updatesys() {
    sh $HOME/update.sh
}
#}}}
# -- sgpt shell integration() seamless command AI creation --{{{
_sgpt_zsh() {
if [[ -n "$BUFFER" ]]; then
    _sgpt_prev_cmd=$BUFFER
    BUFFER+="⌛"
    zle -I && zle redisplay
    BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd" --no-interaction)
    zle end-of-line
fi
}
zle -N _sgpt_zsh
bindkey "^l" _sgpt_zsh
#}}}
# -- historystat() history statistics --{{{
historystat() {
    history 0 | awk '{ if ($2 == "sudo") {print $3} else {print $2} }' | awk -v "FS=|" '{print $1}' | sort | uniq -c | sort -r -n | head -15
}
#}}}
# -- _isInstalled() check if the package is installed --{{{
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
#}}}
# -- _install() install <pkg> --{{{
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
#}}}
# -- _installMany() installMany <pkg1> <pkg2> ... --{{{
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
#}}}
# -- list_apps() list all user installed software with description --{{{
list_apps() {

    for line in "$(pacman -Qqe)"; do pacman -Qi $(echo "$line") ; done | perl -pe 's/ +/ /gm' | perl -pe 's/^(Groups +: )(.*)/$1($2)/gm' | perl -0777 -pe 's/^Name : (.*)\nVersion :(.*)\nDescription : ((?!None).*)?(?:.|\n)*?Groups :((?! \(None\)$)( )?.*)?(?:.|\n(?!Name))+/$1$2$4\n    $3/gm' | grep -A1 --color -P "^[^\s]+"
}
#}}}
# -- ape2flac() Run function to convert .ape -> .flac --{{{
# function to convert .ape file to .flac file
# run from the relevant directory
ape2flac() {
find . -name "*.ape" -exec sh -c 'exec ffmpeg -i "$1" "${1%.ape}.flac"' _ {} \;
}
#}}}
# -- cue2flac() Run function to split flac files from cue sheet --{{{
# function to split individual flac files from cue sheet
# output is <nr>-<SongName>
# run from relevant directory
cue2flac() {
find . -name "*.cue" -exec sh -c 'exec shnsplit -f "$1" -o flac -t "%n-%t" "${1%.cue}.flac"' _ {} \;
}
#}}}
# -- tag2flac() Run function to tag flac files from cue sheet --{{{
# function to tag flac files from cue sheet
# remove the unsplit flac file FIRST!
tag2flac() {
    echo "please remove the unsplit (large) .flac file FIRST!!"
    find . -name "*.cue" -execdir sh -c 'exec cuetag.sh "$1" *.flac' _ {} \;
} 
#}}}
# -- wav2flac() Run function to convert .wav -> flac --{{{
# run from relevant directory
wav2flac() {
      find . -name "*.wav" -exec sh -c 'exec ffmpeg -i "$1" "${1%.wav}.flac"' _ {} \;
}
#}}}
# -- zshcomp() zsh completion --{{{
# Display all autocompleted command in zsh.
# First column: command name Second column: completion function
zshcomp() {
    for command completion in ${(kv)_comps:#-*(-|-,*)}
    do
        printf "%-32s %s\n" $command $completion
    done | sort
}
#}}}
# -- rga-fzf() ripgrep-all and fzf intergation as per t.ly/fCsVn --{{{
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
#}}}
# -- fif() Find in File using ripgrep --{{{
fif() {
  if [ ! "$#" -gt 0 ]; then return 1; fi
  rg --files-with-matches --no-messages "$1" \
      | fzf --preview "highlight -O ansi -l {} 2> /dev/null \
      | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
      || rg --ignore-case --pretty --context 10 '$1' {}"
}
#}}}
# -- fifa() Find in file using ripgrep-all --{{{
fifa() {
    if [ ! "$#" -gt 0 ]; then return 1; fi
    local file
    file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$*" \
        | fzf-tmux -p +m --preview="rga --ignore-case --pretty --context 10 '"$*"' {}")" \
        && print -z "./$file" || return 1;
}
#}}}
# -- list() to show in nnn mime-type of files (nnn related) --{{{
# posible types: audio, video, image, text, application, font
# for full list google "common mime types"
# to show video files, run: list video
list ()                                                                                                    
{
    find . -maxdepth 1 | file -if- | grep "$1" | awk -F: '{printf "%s\0", $1}' | nnn
    # fd -d 1 | file -if- | grep "$1" | awk -F: '{printf "%s\0", $1}' | nnn
}
#}}}
# -- screenshot() Take a screenshot --{{{
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
#}}}
# -- an() notetaking function --{{{
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
#}}}
# -- cfg-...() core configurations --{{{
cfg-zshrc() {chezmoi edit /home/ssserpent/.config/zsh/.zshrc ;}
cfg-zshenv() {chezmoi edit /home/ssserpent/.zshenv ;}
cfg-zprofile() {chezmoi edit /home/ssserpent/.config/zsh/.zprofile ;}
cfg-aliases() {chezmoi edit /home/ssserpent/.config/zsh/aliases ;}
cfg-scripts() {chezmoi edit /home/ssserpent/.config/zsh/scripts.sh ;}
cfg-xinit() {chezmoi edit /home/ssserpent/.config/X11/.xinitrc ;}
cfg-xresources() {chezmoi edit /home/ssserpent/.config/X11/.Xresources ;}
cfg-xauthority() {chezmoi edit /home/ssserpent/.Xauthority ;}
#}}}
# -- cfg-...() apps configurations -- {{{
cfg-aria2() {chezmoi edit /home/ssserpent/.aria2/aria2.conf ;}
cfg-afew() {chezmoi edit /home/ssserpent/.config/afew/config}
cfg-atuin() {chezmoi edit /home/ssserpent/.config/atuin/config.toml ;}
cfg-bat() {chezmoi edit /home/ssserpent/.config/bat/config ;}
cfg-btop() {chezmoi edit /home/ssserpent/.config/btop/btop.conf ;}
cfg-calcurse() {chezmoi edit /home/ssserpent/.config/calcurse/conf ;}
cfg-chezmoi() {$EDITOR /home/ssserpent/.config/chezmoi/chezmoi.toml ;}
cfg-chezmoiexternal() {$EDITOR /home/ssserpent/.config/local/share/chezmoi/.chezmoiexternal.toml ;}
cfg-dmenu() {chezmoi edit /home/ssserpent/.config/dmenufm/dmenufm.conf ;}
cfg-dunst() {chezmoi edit /home/ssserpent/.config/dunst/dunstrc ;}
cfg-epy() {chezmoi edit /home/ssserpent/.config/epy/configuration.json ;}
cfg-htop() {chezmoi edit /home/ssserpent/.config/htop/htoprc ;}
cfg-i3conf() {chezmoi edit /home/ssserpent/.config/i3/config ;}
cfg-i3blocks() {chezmoi edit /home/ssserpent/.config/i3/i3blocks.conf ;}
cfg-i3status() {chezmoi edit /home/ssserpent/.config/i3/i3status.conf ;}
cfg-kitty() {chezmoi edit /home/ssserpent/.config/kitty/kitty.conf ;}
cfg-session() {chezmoi edit /home/ssserpent/.config/kitty/session ;}
cfg-msmtp() {chezmoi edit /home/ssserpent/.config/msmtp/config ;}
cfg-mutt() {chezmoi edit /home/ssserpent/.config/mutt/muttrc ;}
cfg-navi() {chezmoi edit /home/ssserpent/.config/navi/config.yaml ;}
cfg-neofetch() {chezmoi edit /home/ssserpent/.config/neofetch/config.conf ;}
cfg-newsboat() {chezmoi edit /home/ssserpent/.config/newsboat/config ;}
cfg-newsboaturls() {chezmoi edit /home/ssserpent/.config/newsboat/urls ;}
cfg-notmuch() {chezmoi edit /home/ssserpent/.config/notmuch/.notmuch-config ;}
cfg-nvim() {chezmoi edit /home/ssserpent/.config/nvim/init.vim ;}
cfg-ranger() {chezmoi edit /home/ssserpent/.config/ranger/rc.conf ;}
cfg-rangercommands() {chezmoi edit /home/ssserpent/.config/ranger/commands.py ;}
cfg-rofi() {chezmoi edit /home/ssserpent/.config/rofi/ssserpent.rasi ;}
cfg-sgpt() {chezmoi edit /home/ssserpent/.config/shell_gpt/.sgptrc ;}
cfg-solaar() {chezmoi edit /home/ssserpent/.config/solaar/config.yaml ;}
cfg-stig() {chezmoi edit /home/ssserpent/.config/stig/rc ;}
cfg-surfraw() {chezmoi edit /home/ssserpent/.config/surfraw/conf ;}
cfg-termscp() {chezmoi edit /home/ssserpent/.config/termscp/config.toml ;}
cfg-tmux() {chezmoi edit /home/ssserpent/.config/tmux/tmux.conf ;}
cfg-tsm() {chezmoi edit /home/ssserpent/.config/transmission-daemon/settings.json ;}
cfg-vlc() {chezmoi edit /home/ssserpent/.config/vlc/vlcrc ;}
cfg-ytfzf() {chezmoi edit /home/ssserpent/.config/ytfzf/conf.sh ;}
cfg-zathura() {chezmoi edit /home/ssserpent/.config/zathura/zathurarc ;}
cfg-digicamsystem() {chezmoi edit /home/ssserpent/.config/digikam_systemrc ;}
cfg-digikam() {chezmoi edit /home/ssserpent/.config/digikamrc ;}
cfg-mimelist() {chezmoi edit /home/ssserpent/.config/mimeapps.list ;}
cfg-starship() {chezmoi edit /home/ssserpent/.config/starship.toml ;}
cfg-userdirs() {chezmoi edit /home/ssserpent/.config/user-dirs.dirs ;}
cfg-gitconfig() {chezmoi edit /home/ssserpent/.gitconfig ;}
cfg-mbsyncrc() {chezmoi edit /home/ssserpent/.mbsyncrc ;}
cfg-msmtprc() {chezmoi edit /home/ssserpent/.msmtprc ;}
cfg-pamgnupg() {chezmoi edit /home/ssserpent/.pam-gnupg ;}
cfg-urlview() {chezmoi edit /home/ssserpent/.urlview ;}
cfg-xbindkeys() {chezmoi edit /home/ssserpent/.xbindkeysrc ;}
cfg-apps() {chezmoi edit /home/ssserpent/apps.csv ;}
cfg-w3m() {chezmoi edit /home/ssserpent/.w3m/config ;}
cfg-w3mkeymap() {chezmoi edit /home/ssserpent/.w3m/keymap ;}
cfg-w3mmailcap() {chezmoi edit /home/ssserpent/.w3m/mailcap ;}
cfg-w3murimethodmap() {chezmoi edit /home/ssserpent/.w3m/urimethodmap ;}
cfg-dir() {chezmoi edit /home/ssserpent/.bash/scripts/backup/dir.csv ;}
cfg-backup() {chezmoi edit /home/ssserpent/.bash/scripts/backup/backup.sh ;}
# cfg-() {chezmoi edit ;}
#}}}
# -- rld-...() configurations reload --{{{
# rld-bashrc() { source ~/.bashrc ;}
rld-font() { fc-cache -v -f ;}
rld-grub() { sudo grub-mkconfig -o /boot/grub/grub.cfg ;}
rld-greenclip() { killall greenclip ; nohup greenclip daemon > /dev/null 2>&1 & }
# rld-keynav() { killall keynav ; keynav daemonize ;}
rld-updatedb() { sudo updatedb ;}
# rld-rawdog() { rawdog -Wuwv ;}
rld-xbindkeys() { killall xbindkeys ; xbindkeys ;}
# rld-hyperkey() { xmodmap ~/.Xmodmap; killall xcape ; xcape -e 'Hyper_L=Return' ; killall xbindkeys ; xbindkeys ;}
# rld-xcape() { killall xcape ; xcape -e 'Hyper_L=Return' ;}
# rld-xdefaults() { xrdb ~/.Xdefaults ;}
# rld-xmodmap() { xmodmap ~/.Xmodmap ;}
# rld-xmodmap-uskeyboardlayout() { setxkbmap -layout us ;} # reset back to US keyboard http://unix.stackexchange.com/a/151046
rld-xresources() { xrdb -load ~/.Xresources ;}
rld-zshrc() { source ~/.config/zsh/.zshrc ;}
rld-samba() { sudo systemctl restart nmb.service smb.service ;}
rld-zshenv() { source ~/.zshenv ;}
rld-aliases() { source ~/.config/zsh/aliases ;}
rld-scripts() {source ~/.config/zsh/scripts.sh ;}
#}}}
# -- tsm-...() Transmission CLI v2 --{{{
# DEMO: http://www.youtube.com/watch?v=ee4XzWuapsE
# DESC: lightweight torrent client; interface from cli, webui, ncurses, and gui
# WEBUI:  http://localhost:9091/transmission/web/
# 	  http://192.168.1.xxx:9091/transmission/web/
tsm-clearcompleted() {
  transmission-remote -l | grep 100% | grep Done | \
  awk '{print $1}' | xargs -n 1 -I % transmission-remote -t % -r
}
# display numbers of ip being blocked by the blocklist (credit: smw from irc #transmission)
tsm-count() {
  echo "Blocklist rules:" $(curl -s --data \
  '{"method": "session-get"}' localhost:9091/transmission/rpc -H \
  "$(curl -s -D - localhost:9091/transmission/rpc | grep X-Transmission-Session-Id)" \
  | cut -d: -f 11 | cut -d, -f1)
}
# DEMO: http://www.youtube.com/watch?v=TyDX50_dC0M
# DESC: merge multiple ip blocklist into one
# LINK: https://github.com/gotbletu/shownotes/blob/master/blocklist.sh
tsm-blocklist() {
  echo -e "${Red}>>>Stopping Transmission Daemon ${Color_Off}"
    killall transmission-daemon
  echo -e "${Yellow}>>>Updating Blocklist ${Color_Off}"
    ~/.scripts/blocklist.sh
  echo -e "${Red}>>>Restarting Transmission Daemon ${Color_Off}"
    transmission-daemon
    sleep 3
  echo -e "${Green}>>>Numbers of IP Now Blocked ${Color_Off}"
    tsm-count
}
tsm-altdownloadspeed() { transmission-remote --downlimit "${@:-900}" ;}	# download default to 900K, else enter your own
tsm-altdownloadspeedunlimited() { transmission-remote --no-downlimit ;}
tsm-limitupload() { transmission-remote --uplimit "${@:-10}" ;}	# upload default to 10kpbs, else enter your own
tsm-limituploadunlimited() { transmission-remote --no-uplimit ;}
tsm-askmorepeers() { transmission-remote -t"$1" --reannounce ;}
tsm-daemon() { transmission-daemon ;}
tsm-quit() { killall transmission-daemon ;}
tsm-add() { transmission-remote --add "$1" ;}
tsm-hash() { transmission-remote --add "magnet:?xt=urn:btih:$1" ;}       # adding via hash info
tsm-verify() { transmission-remote --verify "$1" ;}
tsm-pause() { transmission-remote -t"$1" --stop ;}		# <id> or all
tsm-start() { transmission-remote -t"$1" --start ;}		# <id> or all
tsm-purge() { transmission-remote -t"$1" --remove-and-delete ;} # delete data also
tsm-remove() { transmission-remote -t"$1" --remove ;}		# leaves data alone
tsm-info() { transmission-remote -t"$1" --info ;}
tsm-speed() { while true;do clear; transmission-remote -t"$1" -i | grep Speed;sleep 1;done ;}
tsm-grep() { transmission-remote --list | grep -i "$1" ;}
tsm() { transmission-remote --list ;}
tsm-show() { transmission-show "$1" ;}                          # show .torrent file information

# DEMO: http://www.youtube.com/watch?v=hLz7ditUwY8
# LINK: https://github.com/fagga/transmission-remote-cli
# DESC: ncurses frontend to transmission-daemon
tsm-ncurse() { transmission-remote-cli ;}
#}}}
