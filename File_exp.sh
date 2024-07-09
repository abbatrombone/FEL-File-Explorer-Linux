#!/usr/bin/env bash

#####################################
# NOTE                              #
#####################################

#Color   Description
#Bold Blue   Directories.
#Uncolored   File or multi-hard link.
#Bold Cyan   A symbolic link pointing to a file.
#Bold Green  An executable file (scripts with having an .sh extension).
#Bold Red    Archive file (mostly a tarball or zip file).
#Magenta Indicates images and video files.
#Cyan    Audio files.
#Yellow with black bg    A pipe file (known as FIFO).
#Blod red with black bg  A broken symbolic link.
#Uncolored (white) with red bg   Indicates set-user-ID file.
#Black with yellow bg    Indicates set-group-ID file.
#White with blue bg  Shows a sticky directory.
#Blue with green bg  Points to Other-writable directory
#Black with green bg When a directory has characteristics of both sticky and other-writable directories.
#Gray is a temp file

#####################################
# BUGS                              #
#####################################

# might have issues with files with next line charater
# refresh means you need to exit multiple times
 
#####################################
# Imporovements                     #
#####################################

#val=FoOz
#[[ ${val,,*} == fooz ]] && echo true

tput civis # makes cursor invisable

if ! org.gnome.desktop.peripherals.keyboard repeat false || ! xset r off || ! xset -r 111 r off || ! xset -r 116 r off ; then
repeatsetting="off";

case $XDG_CURRENT_DESKTOP in

    *GNOME*) 
    gsettings set org.gnome.desktop.peripherals.keyboard repeat false;
    stty sane
    ;;

    "KDE")
    xset r off
    #xset -r 111 r off
    #xset -r 116 r off
    ;;

    "Cinnamon")
    xset r off
    ;;

    "Deepin")
    xset r off
    ;;

    "MATE")
    xset r off
    ;;

    "Xfce")
    xset r off
    ;;

    "Pantheon")
    xset r off
    ;;

    "Budgie")
    xset r off
    ;;
esac

fi

trap "choose_from_menu;" WINCH
trap "ctrl_c" INT

echo -en "\ec\e[37;40m\e[J" #\ec[37 is the text color; 40m is the background \e[J is how much of the screen

Middle=$((COLUMNS/2))
Dir=$(pwd)

MARK='\e[37;44m\e[J'
RESET='\e[27m'
UNMARK='\e[7m'

exit_shortcut="ext = exit"
back_shortcut="bck = back"
refresh_shortcut="ref = refresh"
shortcut_length=37
colorcodetext=$(($Middle - 17))

autocomplete_on() {
    if [[ "$repeatsetting" == "off" ]]; then
case $XDG_CURRENT_DESKTOP in

    *GNOME*) 
    gsettings set org.gnome.desktop.peripherals.keyboard repeat true && stty sane
    ;;

    "KDE")
    xset r on
    #xset -r 111 r off
    #xset -r 116 r off
    ;;

    "Cinnamon")
    xset r on
    ;;

    "Deepin")
    xset r on
    ;;

    "MATE")
    xset r on
    ;;

    "Xfce")
    xset r on
    ;;
    
    "Pantheon")
    xset r on
    ;;

    "Budgie")
    xset r on
    ;;
esac
fi
}
GIT(){
if [[ ! -d "$Dir/.git" ]]; then
    clear; stty sane
    git init;
    git add README.md; 
    echo "Type what you want the comment to be";
    read -r comment
    git commit -m "$comment";
    git add .;
    git status;
    git branch -M main;
    #$Dir/.git/config
    echo "paste you github key. Make sure it has the correct permissions"
    read -r gitkey
    echo "Username"
    read -r username
    echo "projectname"
    read -r projectname
    filepath="url = https://github.com/$username/$projectname"
    correctfilepath="url = https://$gitkey@github.com/$username/$projectname.git"
    git remote add origin https://github.com/"$username"/"$projectname"
    # left is what its looking for, right is what is being changed.
    git remote add origin main https://github.com/"$username"/"$projectname"; # first time updates git 2nd time runs it correctly
    #sed -i "s#https://github.com/abbatrombone/testprj#teststing#" config
     sed -i "s#https://github.com/$username/$projectname#teststing#" $Dir/.git/config
    git push -u origin main;
    EXIT;
elif [[ -d "$Dir/.git" ]]; then
    clear;
    stty -echo; echo -n $'\e[6n'; read -d R z; stty echo;
    IFS=";" read -ra pos <<< "${z#??}"
    unset IFS
    
    yesno=(
    "yes"
    "no"
            )
    yesnocur=0
    yesnocount=${#yesno[@]} 
    yesnoindex=0
    esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    
    echo "Do you need a new key?:"
    while true
    do
        yesnoindex=0 
        for a in "${yesno[@]}"
        do
            if [ "$yesnoindex" == "$yesnocur" ]
            then tput cup "${pos[0]}" 1; echo -en " >$a " # mark & highlight the current option
            else tput cup "${pos[0]}" 7; echo -en " $a "

            fi
            yesnoindex=$(( $yesnoindex + 1 ))
        done
        read -s -n3 yesnokey # wait for user to key in arrows or ENTER
        if [[ $yesnokey == $esc[D ]] # right arrow
        then yesnocur=$(( $yesnocur - 1 ))
            [ "$yesnocur" -lt 0 ] && yesnocur=$(( $yesnocount - 1 ))
        elif [[ $yesnokey == $esc[C ]] # left arrow
        then yesnocur=$(( $yesnocur + 1 ))
            [ "$yesnocur" -ge $yesnocount ] && yesnocur=0 
        elif [[ $yesnokey == "" ]] # nothing, i.e the read delimiter - ENTER
        then break
        fi
        echo -en "\e[${yesnocount}A" # go up to the beginning to re-render
    done

echo "Selected choice: ${yesno[$yesnocur]}"

    if [[ "${yesno[$yesnocur]}" == "yes" ]]; then
        echo "paste you github key. Make sure it has the correct permissions"
        read -r gitkey
    fi
    filepath="url = https://github.com/$username/$projectname"
    correctfilepath="url = https://$gitkey@github.com/$username/$projectname.git"
    git add .
    sleep 1
    git status;
    sleep 1
    git remote add origin main https://github.com/"$username"/"$projectname";
    sleep 1
    git push -u origin main;
fi

}
ctrl_c() { tput cup $Middle 1; echo -e "\ec\e[37;40mCtrl + C has been disabled for this script"; };
TPUT(){ echo -en "\e[${1};${2}H";}
BOX(){ for (( x = 1; x <= LINES; x++ )); do
      for (( y = 1; y <= COLUMNS; y++ )); do
          if (( 1 == x && y == COLUMNS )); then printf "\u2510" 
          elif (( 1 == x && y == 1 )); then printf "\u250C" fi
          elif (( 3 == x && y == 1 )); then printf "\u251C" fi
          elif (( 3 == x && y == COLUMNS || $((LINES-2)) == x && y == COLUMNS)); then printf "\u2524" fi
          elif (( $((LINES-2)) == x && y == 1 )); then printf "\u251C" fi
          elif (( LINES == x && y == COLUMNS )); then printf "\u2518" fi
          elif (( LINES == x && y == 1 )); then printf "\u2514" 
        elif (( 1 == y || COLUMNS == y )); then
            printf  "\u2502"
        elif ((x == 1 || 3 == x || x == LINES || x == $((LINES-2)) )); then
            printf '\u2500'
        else
            echo -n " "
         fi
      done
     done;  };
EXIT() { autocomplete_on; tput cvvis; stty sane echo; clear; exit;}; #Custom


# Makes Menu options
IFS=''
selections=( $(find . -maxdepth 1 -type d -and ! -name . ) )
unset IFS

readarray -t sorted_selections < <(IFS=$'\n'; sort <<<"${selections[*]}")
for ((i=0; i<${#sorted_selections[@]}; i++)); do
  sorted_selections[i]=${sorted_selections[i]:2}
done

for ((c=0; c<${#sorted_selections[@]}; c++)); do
sorted_selections[c]="\033[0;34m\033[40m${sorted_selections[c]}\033[0m";        
done

sorted_selections+=('Go Back')
sorted_selections+=('Exit')

# Sorts and colors files in current file.
IFS=$'\n'
    current_file_previews=( $(find . -maxdepth 1 -type f) )
unset IFS

IFS=''
    current_executable_files=( $(find . -maxdepth 1 -type f -perm -u+x ) )
unset IFS 

readarray -t sorted_current_executable < <(IFS=$'\n'; sort <<<"${current_executable_files[*]}")
for ((sce=0; sce<${#sorted_current_executable[@]}; sce++)); do
     sorted_current_executable[sce]=${sorted_current_executable[sce]:2}
done
unset IFS

current_exe_print=()

for ce in "${current_file_previews[@]}"; do
 if echo "${sorted_current_executable[@]}" | grep -q "$ce"; then # Check if the element is not present in array2
    current_exe_print+=("$ce")
 fi
done

function choose_from_menu() {
   
    local prompt="${UNMARK}$1${RESET}" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]}  index=0
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    midprmt=$((Middle-$((${#prompt}/2))))
    displaynumber=$(($LINES-7))

    while true
    do
        echo -en "\ec\e[37;40m\e[J" #\ec[37 is the text color; 40m is the background \e[J is how much of the screen
        BOX;
   tput cup 1 $midprmt; printf "%s $prompt\n";
        # list all options (arrays start at 0)
        index=0 
        for o in "${options[@]}"
        do
            if [ "$index" == "$cur" ] || [ -d "$o" ]
            then  tput cup $(("$index"+3)) $Middle; echo -e "\033[0;37m\033[40m>\033[0m\e[31m$o\e[40m\033[0m"; # mark & highlight the current option plus 3 is to place it under the prompt
                  if [ "$index" == "$cur" ] || [ -d "$o" ] && [ ! "$o" == "Go Back" ] && [ ! "$o" == "Exit" ]; then 
                    next=${options[index]:18}
                    next2=${next::-7}
                tput cup 3 1; echo -en "\e[37;40mFolder Preveiw:" 
                IFS=$'\n'
                previews=( $(find "$next2" -maxdepth 1 -type d -and ! -name "$next2") )
                unset IFS              
                for ((j=0; j < ${#previews[@]}; j++ )); 
                    do tput cup $((4+j)) 1; printf '\e[1;34m\e[40m%s\e[0m' "${previews[$j]}"; 
                done 
                tput cup $(( LINES - 2 )) $(($((COLUMNS/2)) - 17)); echo -en "\033[0m\033[1;31mArchive\033[0m \033[1;35mImage\033[0m \033[1;34mFolder\033[0m \033[1;37mTemp\033[0m \033[1;32mExecutable\033[0m"
    
                if [[  "$shortcut_length" -lt "$colorcodetext" ]]; then    
                tput cup $(( LINES - 2 )) 2; echo -en "$exit_shortcut";
                tput cup $(( LINES - 2 )) $((3 +${#exit_shortcut})); echo -en "$back_shortcut";
                tput cup $(( LINES - 2 )) $((4 +${#exit_shortcut}+ ${#back_shortcut})); echo -en "$refresh_shortcut";
                elif [[ "$shortcut_length" -gt "$colorcodetext" ]]; then
                tput cup 1 $((COLUMNS-2-${#exit_shortcut})); echo -en "$exit_shortcut";
                tput cup 1 2; echo -en "$back_shortcut";
                tput cup $(( LINES - 2 )) 2; echo -en "$refresh_shortcut";
                fi

                tput cup $(( LINES - 4 )) $colorcodetext; echo "DEBUGGER: $Middle | $((4 +${#exit_shortcut}+ ${#back_shortcut}+ ${#refresh_shortcut})) $repeatsetting $XDG_CURRENT_DESKTOP ${#options[@]} $cur $OLDPWD $next2 "
                    if [ "$index" == "$cur" ] && [ ! "$o" == "Go Back" ] && [ ! "$o" == "Exit" ]; then
                        IFS=$'\n'
                            file_previews=( $(find "$next2" -maxdepth 1 -type f) )
                        unset IFS

                        IFS=''
                            executable_files=( $(find "$next2" -maxdepth 1 -type f -perm -u+x ) )
                        unset IFS 

                        readarray -t sorted_executable < <(IFS=$'\n'; sort <<<"${executable_files[*]}")
                        for ((sti=0; sti<${#sorted_executable[@]}; sti++)); do
                             sorted_executable[sti]=${sorted_executable[sti]:2}
                        done
                        unset IFS

                        exe_print=()

                            for e in "${file_previews[@]}"; do
                             if echo "${sorted_executable[@]}" | grep -q "$e"; then # Check if the element is not present in array2
                                    exe_print+=("$e")
                                fi
                            done

                            tput cup 3 50; printf "\e[37;40mFile Preveiw:"
                    for ((fp=0; fp < ${#file_previews[@]}; fp++ )); do 
                        if [[ ${file_previews[$fp]} == *.a || ${file_previews[$fp]} == *.ar || ${file_previews[$fp]} == *.cpio || ${file_previews[$fp]} == *.shar || ${file_previews[$fp]} == *.tar || ${file_previews[$fp]} == *.zip || ${file_previews[$fp]} == *.rar || ${file_previews[$fp]} == *.7z || ${file_previews[$fp]} == *.pkg || ${file_previews[$fp]} == *.deb || ${file_previews[$fp]} == *.msu || ${file_previews[$fp]} == *.cab || ${file_previews[$fp]} == *.ear || ${file_previews[$fp]} == *.jar || ${file_previews[$fp]} == *.war || ${file_previews[$fp]} == *.phar || ${file_previews[$fp]} == *.zipx || ${file_previews[$fp]} == *.rarx || ${file_previews[$fp]} == *.7zx || ${file_previews[$fp]} == *.lzma || ${file_previews[$fp]} == *.xz || ${file_previews[$fp]} == *.zst || ${file_previews[$fp]} == *.lz4 || ${file_previews[$fp]} == *.zlib || ${file_previews[$fp]} == *.ecsbx || ${file_previews[$fp]} == *.par || ${file_previews[$fp]} == *.par2 || ${file_previews[$fp]} == *.rev || ${file_previews[$fp]} == *.LBR || ${file_previews[$fp]} == *.LQR || ${file_previews[$fp]} == *.SDA || ${file_previews[$fp]} == *.SFX || ${file_previews[$fp]} == *.YZ1 ]]; then
                            tput cup $((4+fp)) 50; printf '\e[1;31m\e[40m%s\e[0m' "${file_previews[$fp]}"; #did not end in normal to stop background color from needing to be updated.
                        elif [[ ${file_previews[$fp]} == *.bmp || ${file_previews[$fp]} == *.jpg || ${file_previews[$fp]} == *.jpeg || ${file_previews[$fp]} == *.png || ${file_previews[$fp]} == *.pen || ${file_previews[$fp]} == *.tif || ${file_previews[$fp]} == *.tiff || ${file_previews[$fp]} == *.gif || ${file_previews[$fp]} == *.svg || ${file_previews[$fp]} == *.ai || ${file_previews[$fp]} == *.raw || ${file_previews[$fp]} == *.cr2 || ${file_previews[$fp]} == *.nef || ${file_previews[$fp]} == *.MP4 || ${file_previews[$fp]} == *.AVI || ${file_previews[$fp]} == *.MOV || ${file_previews[$fp]} == *.WMV || ${file_previews[$fp]} == *.FLV ]]; then
                            tput cup $((4+fp)) 50; printf '\e[1;35m\e[40m%s\e[0m' "${file_previews[$fp]}"; #did not end in normal to stop background color from needing to be updated.    
                        elif [[ ${file_previews[$fp]} == *.tmp  ]]; then
                            tput cup $((4+fp)) 50; printf '\e[1;37m\e[40m%s\e[0m' "${file_previews[$fp]}"; #did not end in normal to stop background color from needing to be updated. 
                        elif  echo "${sorted_executable[@]}" | grep -q "$fp"; then 
                            for item in "${!sorted_executable[@]}"; do
                                if [[ ${executable_files[$item]} ]]; then
                                    tput cup $((4+fp)) 50; printf '\e[1;32m\e[40m%s\e[0m' "${file_previews[$fp]}";   
                                fi
                            done
                        else tput cup $((4+fp)) 50; printf '\e[1;37m\e[40m%s%s' "${file_previews[$fp]}";
                        fi  
                    done 
                     fi

            fi
            elif [ "$index" == "$cur" ] || [ ! -d "$o" ]; then  tput cup $(("$index"+3)) $Middle; echo -e "\033[0;107m$o\e[40m \e[0m"; 
            elif [ "$index" != "$cur" ];   then tput cup $(("$index"+3)) $Middle; echo -e "\033[40m${MARK} $o${RESET}";
            fi    
       
        index=$(( index + 1 ))
        done

        ##current files

                tput cup 3 125; printf "\e[37;40mTop $displaynumber Files:"
                 for ((fp=0; fp < $displaynumber; fp++ )); do 
                        if [[ ${current_file_previews[$fp]} == *.a || ${current_file_previews[$fp]} == *.ar || ${current_file_previews[$fp]} == *.cpio || ${current_file_previews[$fp]} == *.shar || ${current_file_previews[$fp]} == *.tar || ${current_file_previews[$fp]} == *.zip || ${current_file_previews[$fp]} == *.rar || ${current_file_previews[$fp]} == *.7z || ${current_file_previews[$fp]} == *.pkg || ${current_file_previews[$fp]} == *.deb || ${current_file_previews[$fp]} == *.msu || ${current_file_previews[$fp]} == *.cab || ${current_file_previews[$fp]} == *.ear || ${current_file_previews[$fp]} == *.jar || ${current_file_previews[$fp]} == *.war || ${current_file_previews[$fp]} == *.phar || ${current_file_previews[$fp]} == *.zipx || ${current_file_previews[$fp]} == *.rarx || ${current_file_previews[$fp]} == *.7zx || ${current_file_previews[$fp]} == *.lzma || ${current_file_previews[$fp]} == *.xz || ${current_file_previews[$fp]} == *.zst || ${current_file_previews[$fp]} == *.lz4 || ${current_file_previews[$fp]} == *.zlib || ${current_file_previews[$fp]} == *.ecsbx || ${current_file_previews[$fp]} == *.par || ${current_file_previews[$fp]} == *.par2 || ${current_file_previews[$fp]} == *.rev || ${current_file_previews[$fp]} == *.LBR || ${current_file_previews[$fp]} == *.LQR || ${current_file_previews[$fp]} == *.SDA || ${current_file_previews[$fp]} == *.SFX || ${current_file_previews[$fp]} == *.YZ1 ]]; then
                            tput cup $((4+fp)) 125; printf '\e[1;31m\e[40m%s\e[0m' "${current_file_previews[$fp]:2}"; #did not end in normal to stop background color from needing to be updated.
                        elif [[ ${current_file_previews[$fp]} == *.bmp || ${current_file_previews[$fp]} == *.jpg || ${current_file_previews[$fp]} == *.jpeg || ${current_file_previews[$fp]} == *.png || ${current_file_previews[$fp]} == *.pen || ${current_file_previews[$fp]} == *.tif || ${current_file_previews[$fp]} == *.tiff || ${current_file_previews[$fp]} == *.gif || ${current_file_previews[$fp]} == *.svg || ${current_file_previews[$fp]} == *.ai || ${current_file_previews[$fp]} == *.raw || ${current_file_previews[$fp]} == *.cr2 || ${current_file_previews[$fp]} == *.nef || ${current_file_previews[$fp]} == *.MP4 || ${current_file_previews[$fp]} == *.AVI || ${current_file_previews[$fp]} == *.MOV || ${current_file_previews[$fp]} == *.WMV || ${current_file_previews[$fp]} == *.FLV ]]; then
                            tput cup $((4+fp)) 125; printf '\e[1;35m\e[40m%s\e[0m' "${current_file_previews[$fp]:2}"; #did not end in normal to stop background color from needing to be updated.    
                        elif [[ ${current_file_previews[$fp]} == *.tmp  ]]; then
                            tput cup $((4+fp)) 125; printf '\e[1;37m\e[40m%s\e[0m' "${current_file_previews[$fp]:2}"; #did not end in normal to stop background color from needing to be updated. 
                        elif  echo "${sorted_current_executable[@]}" | grep -q "$fp"; then 
                            for item in "${!sorted_current_executable[@]}"; do
                                if [[ ${current_executable_files[$item]} ]]; then
                                    tput cup $((4+fp)) 125; printf '\e[1;32m\e[40m%s\e[0m' "${current_file_previews[$fp]:2}";   
                                fi
                            done
                        else tput cup $((4+fp)) 125; printf '\e[1;37m\e[40m%s%s' "${current_file_previews[$fp]:2}";
                        fi  
                    done

        read -sr -n3 key && stty -echo # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]] # up arrow
        then cur=$(( cur - 1 )) && clear
            [ "$cur" -lt 0 ] && cur=$(($count -1 )) # count starts at 1 but arrays start at 0
        elif [[ $key == $esc[B ]] # down arrow
        then cur=$(( cur + 1 )) && clear
            [ "$cur" -ge "$count" ] && cur=0
        elif [[ $key == "" ]] # nothing, i.e the read delimiter - ENTER
        then break
        elif [[ $key == "ext" || $key == "EXT" || $key == "Ext" ]]; #keyshortcut exit
        then EXIT;
        elif [[ $key == "bck" || $key == "BCK" || $key == "Bck" ]]; #keyshortcut back
        then cd .. && bash ~/File_exp.sh;
        elif [[ $key == "ref" || $key == "REF" || $key == "Ref" ]]; #keyshortcut refresh
        then xdotool key --sync 'F5'
        elif [[ $key == "git" || $key == "GIT" || $key == "Git" ]]; #keyshortcut git
            then GIT
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render


    done
    # export the selection to the requested output variable
    printf -v "$outvar" "${options[$cur]}"

}
 
choose_from_menu "Current directory: $Dir (.file = hidden)" selected_choice "${sorted_selections[@]}"
tput cup $(( LINES - 4 )) $(($((COLUMNS/2)) - 17)); echo "Selected choice: $selected_choice" 

trimmed_selected_choice=${selected_choice:12}
trimmed_selected_choice=${trimmed_selected_choice::-4}

if [  "$selected_choice" == "Go Back" ]
  then cd .. && bash ~/File_exp.sh
elif [[ "$selected_choice" == "Exit" ]]; then EXIT;
else cd & cd "$trimmed_selected_choice"; sleep 2; bash ~/File_exp.sh
fi

clear;

: '

IFS=''
 archive_files=( $( find "$next2" -maxdepth 1 -type f -name "*.a" -o -name "*.ar" -o -name "*.cpio" -o -name "*.shar" -o -name "*.tar" -o -name "*.zip" -o -name "*.rar" -o -name "*.7z" -o -name "*.pkg" -o -name "*.deb" -o -name "*.msu" -o -name "*.cab" -o -name "*.ear" -o -name "*.jar" -o -name "*.war" -o -name "*.phar" -o -name "*.zipx" -o -name "*.rarx" -o -name "*.7zx" -o -name "*.lzma" -o -name "*.xz" -o -name "*.zst" -o -name "*.lz4" -o -name "*.zlib" -o -name "*.ecsbx" -o -name "*.par" -o -name "*.par2" -o -name "*.rev" -o -name "*.LBR" -o -name "*.LQR" -o -name "*.SDA" -o -name "*.SFX" -o -name "*.YZ1"  ) )
unset IFS 

readarray -t sorted_archive < <(IFS=$'\n'; sort <<<"${archive_files[*]}")
for ((afi=0; afi<${#sorted_archive[@]}; afi++)); do
  sorted_archive[afi]=${sorted_archive[afi]:2}
  sorted_archive[afi]="\033[0;31m\033[40m${sorted_archive[afi]}\033[0m";
  #echo -e " $afi ${sorted_archive[afi]} "
done
unset IFS

IFS=''
 imagie_files=( $( find "$next2" -maxdepth 1 -type f -name "*.bmp" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.pen" -o -name "*.tif" -o -name "*.tiff" -o -name "*.gif" -o -name "*.svg" -o -name "*.ai" -o -name "*.raw" -o -name "*.cr2" -o -name "*.nef" -o -name "*.MP4" -o -name "*.AVI" -o -name "*.MOV" -o -name "*.WMV" -o -name "*.FLV") )
unset IFS 

readarray -t sorted_imagie < <(IFS=$'\n'; sort <<<"${imagie_files[*]}")
for ((si=0; si<${#sorted_imagie[@]}; si++)); do
   sorted_imagie[si]=${sorted_imagie[si]:2}
  sorted_imagie[si]="\033[0;35m\033[40m${sorted_imagie[si]}\033[0m";
  #echo -e " $si ${sorted_imagie[si]} "
done
unset IFS

IFS=''
 temp_files=( $( find "$next2" -maxdepth 1 ! -name . ! -name .. -print | sort | awk '/.tmp/' ) )
unset IFS 

readarray -t sorted_temp < <(IFS=$'\n'; sort <<<"${temp_files[*]}")
for ((sti=0; sti<${#sorted_temp[@]}; sti++)); do
  sorted_temp[sti]=${sorted_temp[sti]:2}
  sorted_temp[sti]="\033[0;37m\033[40m${sorted_temp[sti]}\033[0m";
  #echo -e " $sti ${sorted_temp[sti]} "
done
unset IFS

IFS=''
executable_files=( $(find "$next2" -maxdepth 1 -type f -perm -u+x ) )
unset IFS 

readarray -t sorted_executable < <(IFS=$'\n'; sort <<<"${executable_files[*]}")
for ((sti=0; sti<${#sorted_executable[@]}; sti++)); do
  sorted_executable[sti]=${sorted_executable[sti]:2}
  sorted_executable[sti]="\033[0;32m\033[40m${sorted_executable[sti]}\033[0m";
  #echo -e " $sti ${sorted_executable[sti]} "
done
unset IFS

IFS=''
all_files=( $(find tput cup $((4+fp)) 150; -maxdepth 1 -type f ) )
unset IFS 

array+=${sorted_archive[@]}
array+=" "
array+=${sorted_imagie[@]}
array+=" "
array+=${sorted_temp[@]}
array+=" "
array+=${sorted_executable[@]}

readarray -t sorted_all < <(IFS=$'\n'; sort <<<"${all_files[*]}")
for ((a=0; a<${#sorted_all[@]}; a++)); do
  sorted_all[a]=${sorted_all[a]:2}
  if [[ ! " ${sorted_all[a]} " =~ " ${array[@]} " ]]; then
    echo -e "${sorted_all[a]} "
fi
  
done
unset IFS

find . -maxdepth 1 -type f \( -not -perm -u+x -a -not -name "*.bmp" -a -not -name "*.jpg" -a -not -name "*.jpeg" -a -not -name "*.png" -a -not -name "*.pen" -a -not -name "*.tif" -a -not -name "*.tiff" -a -not -name "*.gif" -a -not -name "*.svg" -a -not -name "*.ai" -a -not -name "*.raw" -a -not -name "*.cr2" -a -not -name "*.nef" -a -not -name "*.MP4" -a -not -name "*.AVI" -a -not -name "*.MOV" -a -not -name "*.WMV" -a -not -name "*.FLV" -a -not -name "*.a" -a -not -name "*.ar" -a -not -name "*.cpio" -a -not -name "*.shar" -a -not -name "*.tar" -a -not -name "*.zip" -a -not -name "*.rar" -a -not -name "*.7z" -a -not -name "*.pkg" -a -not -name "*.deb" -a -not -name "*.msu" -a -not -name "*.cab" -a -not -name "*.ear" -a -not -name "*.jar" -a -not -name "*.war" -a -not -name "*.phar" -a -not -name "*.zipx" -a -not -name "*.rarx" -a -not -name "*.7zx" -a -not -name "*.lzma" -a -not -name "*.xz" -a -not -name "*.zst" -a -not -name "*.lz4" -a -not -name "*.zlib" -a -not -name "*.ecsbx" -a -not -name "*.par" -a -not -name "*.par2" -a -not -name "*.rev" -a -not -name "*.LBR" -a -not -name "*.LQR" -a -not -name "*.SDA" -a -not -name "*.SFX" -a -not -name "*.YZ1" -a -not -name "*.tmp" \) -and -not -name "*.tmp" -and -not -type d

##exclude everying already used for the remainder?
find . -maxdepth 1 -type f -perm -u-x -o ! -name "*.bmp" -o ! -name "*.jpg" -o ! -name "*.jpeg" -o ! -name "*.png" -o ! -name "*.pen" -o ! -name "*.tif" -o ! -name "*.tiff" -o ! -name "*.gif" -o ! -name "*.svg" -o ! -name "*.ai" -o ! -name "*.raw" -o ! -name "*.cr2" -o ! -name "*.nef" -o ! -name "*.MP4" -o ! -name "*.AVI" -o ! -name "*.MOV" -o ! -name "*.WMV" -o ! -name "*.FLV" -o ! -name "*.a" -o ! -name "*.ar" -o ! -name "*.cpio" -o ! -name "*.shar" -o ! -name "*.tar" -o ! -name "*.zip" -o ! -name "*.rar" -o ! -name "*.7z" -o ! -name "*.pkg" -o ! -name "*.deb" -o ! -name "*.msu" -o ! -name "*.cab" -o ! -name "*.ear" -o ! -name "*.jar" -o ! -name "*.war" -o ! -name "*.phar" -o ! -name "*.zipx" -o ! -name "*.rarx" -o ! -name "*.7zx" -o ! -name "*.lzma" -o ! -name "*.xz" -o ! -name "*.zst" -o ! -name "*.lz4" -o ! -name "*.zlib" -o ! -name "*.ecsbx" -o ! -name "*.par" -o ! -name "*.par2" -o ! -name "*.rev" -o ! -name "*.LBR" -o ! -name "*.LQR" -o ! -name "*.SDA" -o ! -name "*.SFX" -o ! -name "*.YZ1"

'

