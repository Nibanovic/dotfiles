#!/bin/bash

# rose-pine main color scheme

export NC='\[\e[0m\]' # No Color
export BLACK='\[\e[0;30m\]'
export GRAY='\[\e[1;30m\]'
export RED='\[\e[0;31m\]'
export LIGHT_RED='\[\e[1;31m\]'
export GREEN='\[\e[0;32m\]'
export LIGHT_GREEN='\[\e[1;32m\]'
export BROWN='\[\e[0;33m\]'
export YELLOW='\[\e[1;33m\]'
export BLUE='\[\e[0;34m\]'
export LIGHT_BLUE='\[\e[1;34m\]'
export PURPLE='\[\e[0;35m\]'
export LIGHT_PURPLE='\[\e[1;35m\]'
export CYAN='\[\e[0;36m\]'
export LIGHT_CYAN='\[\e[1;36m\]'
export LIGHT_GRAY='\[\e[0;37m\]'
export WHITE='\[\e[1;37m\]'

RESET='\[\e[0m\]'
BOLD='\[\e[1m\]'

function get_gitbranch {
  if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then
    git branch --show-current 2> /dev/null
  else
    echo ""
  fi
}

function parse_git_opening_bracket {
  if [[ "$(get_gitbranch)" != '' ]]; then
    echo "<"
  else
    echo ""
  fi
}

function parse_git_closing_bracket {
  if [[ "$(get_gitbranch)" != '' ]]; then
    echo ">"
  else
    echo ""
  fi
}

function set_git_color {
  if [[ "$(get_gitbranch)" != '' ]]; then
    # Get the status of the repo and chose a color accordingly
    local STATUS=$(LANG=en_GB LANGUAGE=en git status 2>&1)
    if [[ "$STATUS" != *'working tree clean'* ]]; then
      # red if need to commit
      color=$RED
    elif [[ "$STATUS" == *'Your branch is ahead'* ]]; then
        # yellow if need to push
        color=$YELLOW
    elif [[ "$STATUS" == *' have diverged,'* ]]; then
      # brown if need to force push
      color=$BROWN
    else
      # else green
      color=$GREEN
    fi
# choosing to declare colors with \[, \] characters around them 
# forced me to do this messy truncation. This script should be refactored.
# It works now, but by bash knowledge prohibits me to do this well atm.
    echo -e "${color:2:-2}"
  fi
}

update_git_branch_name() {
  echo -n $(set_git_color)$(parse_git_opening_bracket)$(get_gitbranch)$(parse_git_closing_bracket)
}
# Set up the prompt
PS1="${BOLD}${BROWN}\W\$(update_git_branch_name)${BOLD}${RED}\$ ${RESET}"

export PS1

# Make the script executable
chmod +x ~/.prompt.sh
