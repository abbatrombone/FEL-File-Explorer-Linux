
# FEL (File Explorer Linux)

## Why Use #!/usr/bin/env bash ? 
There are multiple different ways to tell the system you are using bash. There is `#!/usr/bin/env bash` and `#!/bin/bash`. 
The reason `#!/usr/bin/env bash` is used is because it is more flexible and portable way to specify the interpreter that the shell is going to use. 
Even if the interpreter is installed in atypical location the script should work. This also has the upside of working on different systems with bash without modification as long as the interpreter is installed in the systems PATH. 
This is also suppose to be a more secure method as it is less vulnerable to traversal attacks. 
This comes with a few downsides though mainly it is more complex to de-bug and due to the flexibility the behavior might change if the location of the interpreter changes.

## The Power of the echo Command
Each script also uses the echo command which can just repeat or echo what you tell it. The command takes two arguments e and n. Typically if you have `echo "H" echo "I"` it would print each on its ownline `-n` is there to prevent this. The `-e` allows for the command to interpret backslash-escaped characters like `\n for next line` or `\t for tab`. This is also the reason why the text and background are different colors. There are several other uses for `-e` which are 
* \a    Alert (bell) 
* \b    Backspace
* \c    Suppress trailing newline
* \e    Escape
* \f    Form feed
* \r    Carriage return
* \v    Vertical tab
* \\    Backslash
* \0nnn   The eight-bit character whose value is the octal value nnn (zero to three octal digits) if nnn is not a valid octal number, it is printed literally 
* \xHH    The eight-bit character whose value is the hex value HH (one or two hex digits)
* \uHHHH    The Unicode (ISO/IEC 10646) character whose value is the hex value HHHH (one to four hex digits)
* \UHHHHHHHH  The Unicode (ISO/IEC 10646) character whose value is the hex value HHHHHHHH (one to eight hex digits). The echo command is more powerful then it initially looks and is used frequently throughout the script so it is shorted as a variable with `$e` and `$E` for `-e` and `-en`.

This script uses the escape commands as that is what I am most familiar with and have documentation as to what color is what.

## The Trap Command and Signals
The next command to cover is the trap command. This looks for a signal and then when send signal occurs the logic in the quotes happens. 
`WINCH` is when the terminal size is changed, and `INT` is looking for the close command or `^C` as you might see it. 
Inside the trap command for the menus are not commands but functions that are specified in the script. 

## Conjunction Conjunction What's Your Function?
The function names should be fairly self explanatory but will be covered in case they are not. 

* `Exit` is there to close the program and every subprocess it might have which changes per menu and menu screen. 
* `stty sane` restores the default behavior on the terminal so the script does not have to worry about quirks on each system. 
* `TPUT` cans where the echo statement prints on its x and y position or `$LINES` and `$COLUMNS`. The `1` and `2` are positional parameters which save the custom console input.
* `BOX` draws the box around the terminal
* `ctrl_c` runs when the program is forced to close, and tells you it does not allow that 
* `autocomplete_on` turns auto complete back on if at the start of the script it was turned off.

## WTF is is IFS
IFS stands for internal field separator. This is used to separate each element (part) of the array. `unset IFS` resets it to its default. This needs to be done because of how `readarray -t` is being used to sort the elements in the array.  

## Centering Text
Centering text is annoying in bash and the method used was the best iteration I could make. Each thing that needs to be printed needs to be stored in a variable so its length can be found with `${$var}` and to find half the length `$(())` is used for math in bash. To center is you need to know how long you screen is and how long the word is. Having it print at half the columns means the work starts at the center so the difference is taken between the length of the string and the number of columns, each of which is divided by two to find its center. That is why `$(($up-2)) $(($right-$((${#M0String}/2))))` is written the way it is.

## While
The while statement uses the variable I to keep track of your cursor location if the input is not using the enter key. If it is using the enter key you go into that menu. Anything before the if statement happens when your cursor is over that option. If the if statement is true then it does what the logic tells it to. For example run a basic command or play a sound when selected and a command. To play a sound you will need to use something outside the shell. In the provided example `Jcompile_Menu.sh` `mpv` is used to make sounds. Remember bash or any other shell script goes line by line which means it will wait for the sound to finish if before going on. A user can input buffer by holding down the arrow key, which can cause some issues.

## Why `next=${options[index]:18}` ?!?!
In order to get the color coding to match how ls is set i added the escape codes to each element in the array and when it is selected it needs to be removed being it would read the string with the escape codes and find a file that, most likely, does not exist.
The behavior of adding it for each element in the array was acting werid. For example it would only color the first element, rather than all of them, and after fighting that for awhile, editing the elements was used instead.

## Debugger
There is a line with a debugger which you can comment or uncomment if you need to have it troubleshoot. Currently it prints out a bunch of variables to make sure everything is correct.

##Shortcuts
It may seem odd to have keyboard short cuts at 3 characters. There is a reason though: arrow keys. Arrow keys take 3 characters on the terminal and `read -sr -n3 key` will not do anything until it sees three characters. It would be possiable to change the arrows to wasd and then make each shortcut 1 letter.

## Autocomplete and Buffering Inputs
If buffering inputs is an issue there is a command that can disable what is called autocomplete. For GNU or gnome users the command is gsettings set org.gnome.desktop.peripherals.keyboard repeat false to turn it off and true for allowing autocomplete to occur.
The `if ! org.gnome.desktop.peripherals.keyboard repeat false || ! xset r off || ! xset -r 111 r off || ! xset -r 116 r off ` checks to see if auto complete is off with gsettings or xset. Then goes into the case to find the desktop environment and turn it off there. The repeatsetting variable is there to mark if it needs to be updated at all when exiting the script.
Otherwise `xev` and `showkey` can be used to find the keyboard event. GUIs should be easy and nice to use for users. 

## The Executable array
Grabbing every file is easy with the find command. The output can be stored in an array, but the hard part is telling if it is an executable. Every other file type has an extension making it easy to identify. Here we have to deal with file permissions which is trickier. `u+x` checks if the user has permission to execute the file. This then needs to be compared: 
`for item in "${!sorted_current_executable[@]}"; do
                                if [[ ${current_executable_files[$item]} ]]; then
                                    tput cup $((4+fp)) 125; printf '\e[1;32m\e[40m%s\e[0m' "${current_file_previews[$fp]:2}";   
                                fi`
The code above does the comparison. The for loop goes through each item in both arrays, and compares them. note the for loop uses `${!` when looking at the array. This formatting is the only reason the code works.

## Use Cases
It can be annoying to look in the terminal file by file and go back, especially if you are new to the linux kernal. This can help you explore files in the terminal, and it has built in explanation as to what the color coding is. This can be built upon to have new short cuts to do something in the terminal.

# Credits
* `Guss` GUI desgin: https://askubuntu.com/users/6537/guss
* `Abbatrombone` Funcionality 
* And Other Contrubiters, feel free to add your name here after contrbiting to the project :D 

I am new to git hub so if anything is not current please let me know so it can be corrected.
