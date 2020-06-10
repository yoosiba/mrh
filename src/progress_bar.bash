#!/usr/bin/env bash

# based on # https://github.com/pollev/bash_progress_bar
# TODO consider https://github.com/nachoparker/progress_bar.sh

# Usage:
# Source this script
# enable_trapping <- optional to clean up properly if user presses ctrl-c
# setup_scroll_area <- create empty progress bar
# draw_progress_bar 10 <- advance progress bar
# draw_progress_bar 40 <- advance progress bar
# block_progress_bar 45 <- turns the progress bar yellow to indicate some action is requested from the user
# draw_progress_bar 90 <- advance progress bar
# destroy_scroll_area <- remove progress bar

# Constants
CODE_SAVE_CURSOR="\033[s"
CODE_RESTORE_CURSOR="\033[u"
CODE_CURSOR_IN_SCROLL_AREA="\033[1A"
COLOR_FG="\e[30m"
COLOR_BG="\e[42m"
COLOR_BG_BLOCKED="\e[43m"
RESTORE_FG="\e[39m"
RESTORE_BG="\e[49m"

# Variables
PROGRESS_BLOCKED="false"
TRAPPING_ENABLED="false"
TRAP_SET="false"

setup_scroll_area() {
    # If trapping is enabled, we will want to activate it whenever we setup the scroll area and remove it when we break the scroll area
    if [ "$TRAPPING_ENABLED" = "true" ]; then
        trap_on_interrupt
    fi

    local last_scroll_line # terminal height in lines - 1 line for progress bar
    last_scroll_line=$(($(tput lines) - 1))
    # Scroll down a bit to avoid visual glitch when the screen area shrinks by one row
    echo -en "\n"

    # Save cursor
    echo -en "$CODE_SAVE_CURSOR"
    # Set scroll region (this will place the cursor in the top left)
    echo -en "\033[0;${last_scroll_line}r"

    # Restore cursor but ensure its inside the scrolling area
    echo -en "$CODE_RESTORE_CURSOR"
    echo -en "$CODE_CURSOR_IN_SCROLL_AREA"

    # Start empty progress bar
    draw_progress_bar 0
}

destroy_scroll_area() {
    local progres_bar_line # progress bar line is a last line
    progres_bar_line=$(tput lines)
    # Save cursor
    echo -en "$CODE_SAVE_CURSOR"
    # Set scroll region (this will place the cursor in the top left)
    echo -en "\033[0;${progres_bar_line}r"

    # Restore cursor but ensure its inside the scrolling area
    echo -en "$CODE_RESTORE_CURSOR"
    echo -en "$CODE_CURSOR_IN_SCROLL_AREA"

    # We are done so clear the scroll bar
    clear_progress_bar

    # Scroll down a bit to avoid visual glitch when the screen area grows by one row
    echo -en "\n\n"

    # Once the scroll area is cleared, we want to remove any trap previously set. Otherwise, ctrl+c will exit our shell
    if [ "$TRAP_SET" = "true" ]; then
        trap - INT
    fi
}

draw_progress_bar() {
    percentage=$1
    if ! [[ $percentage =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        destroy_scroll_area
        echo "progress should be a raw number, was $percentage" >&2
        exit 3
    elif (($(echo "$percentage > 100" | bc -l))); then
        destroy_scroll_area
        echo "progress should be below 100, was $percentage" >&2
        exit 3
    elif (($(echo "$percentage < 0" | bc -l))); then
        destroy_scroll_area
        echo "progress should be above 0, was $percentage" >&2
        exit 3
    fi

    local progres_bar_line # progress bar line is a last line
    progres_bar_line=$(tput lines)
    # Save cursor
    echo -en "$CODE_SAVE_CURSOR"

    # Move cursor position to last row
    echo -en "\033[${progres_bar_line};0f"

    # Clear progress bar
    tput el

    # Draw progress bar
    PROGRESS_BLOCKED="false"
    print_bar_text "$percentage"

    # Restore cursor position
    echo -en "$CODE_RESTORE_CURSOR"
}

block_progress_bar() {
    percentage=$1
    local progres_bar_line # progress bar line is a last line
    progres_bar_line=$(tput lines)
    # Save cursor
    echo -en "$CODE_SAVE_CURSOR"

    # Move cursor position to last row
    echo -en "\033[${progres_bar_line};0f"

    # Clear progress bar
    tput el

    # Draw progress bar
    PROGRESS_BLOCKED="true"
    print_bar_text "$percentage"

    # Restore cursor position
    echo -en "$CODE_RESTORE_CURSOR"
}

clear_progress_bar() {
    local progres_bar_line # progress bar line is a last line
    progres_bar_line=$(tput lines)
    # Save cursor
    echo -en "$CODE_SAVE_CURSOR"

    # Move cursor position to last row
    echo -en "\033[${progres_bar_line};0f"

    # clear progress bar
    tput el

    # Restore cursor position
    echo -en "$CODE_RESTORE_CURSOR"
}

print_bar_text() {
    local percentage=$1

    local bar_size # terminal columns - text - percentage lenght
    bar_size=$(($(tput cols) - 17 - ${#percentage}))
    local complete_size # completed columns based on completed percentage
    complete_size=$(echo "scale=2; (($bar_size * $percentage)/100)" | bc)
    local remainder_size # not completed part
    remainder_size=$(echo "scale=2; $bar_size - $complete_size" | bc)

    local color="${COLOR_FG}${COLOR_BG}"
    if [ "$PROGRESS_BLOCKED" = "true" ]; then
        color="${COLOR_FG}${COLOR_BG_BLOCKED}"
    fi
    progress_bar=$(
        echo -ne "["
        echo -en "${color}"
        printf_new "#" "$complete_size"
        echo -en "${RESTORE_FG}${RESTORE_BG}"
        printf_new "." "$remainder_size"
        echo -ne "]"
    )

    # Print progress bar
    echo -ne " Progress ${percentage}% ${progress_bar}"
}

enable_trapping() {
    TRAPPING_ENABLED="true"
}

trap_on_interrupt() {
    # If this function is called, we setup an interrupt handler to cleanup the progress bar
    TRAP_SET="true"
    trap cleanup_on_interrupt INT
}

cleanup_on_interrupt() {
    destroy_scroll_area
    exit
}

printf_new() {
    str=$1
    num=$2
    v=$(printf "%-${num}s" "$str")
    echo -ne "${v// /$str}"
}
