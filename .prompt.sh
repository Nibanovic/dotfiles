#!/bin/bash
# 
# My custom prompt based on the rose-pine color scheme.
# Needs NERDFONTS to display branch icon properly.
#
# rose-pine main color scheme
export BASE='\[\e[38;2;25;23;36m\]'
export SURFACE='\[\e[38;2;31;29;46m\]'
export OVERLAY='\[\e[38;2;38;35;58m\]'
export MUTED='\[\e[38;2;110;106;134m\]'
export SUBTLE='\[\e[38;2;144;140;170m\]'
export TEXT='\[\e[38;2;224;222;224m\]'
export LOVE='\[\e[38;2;235;111;146m\]'
export GOLD='\[\e[38;2;246;193;119m\]'
export ROSE='\[\e[38;2;235;188;186m\]'
export PINE='\[\e[38;2;49;116;143m\]'
export FOAM='\[\e[38;2;156;207;216m\]'
export IRIS='\[\e[38;2;196;167;231m\]'
export HL_LOW='\[\e[38;2;33;32;46m\]'
export HL_MED='\[\e[38;2;64;61;82m\]'
export HL_HIGH='\[\e[38;2;82;79;103m\]'

export BG_BASE='\[\e[48;2;25;23;36m\]'
export BG_SURFACE='\[\e[48;2;31;29;46m\]'
export BG_OVERLAY='\[\e[48;2;38;35;58m\]'
export BG_MUTED='\[\e[48;2;110;106;134m\]'
export BG_SUBTLE='\[\e[48;2;144;140;170m\]'
export BG_TEXT='\[\e[48;2;224;222;224m\]'
export BG_LOVE='\[\e[48;2;235;111;146m\]'
export BG_GOLD='\[\e[48;2;246;193;119m\]'
export BG_ROSE='\[\e[48;2;235;188;186m\]'
export BG_PINE='\[\e[48;2;49;116;143m\]'
export BG_FOAM='\[\e[48;2;156;207;216m\]'
export BG_IRIS='\[\e[48;2;196;167;231m\]'
export BG_HL_LOW='\[\e[48;2;33;32;46m\]'
export BG_HL_MED='\[\e[48;2;64;61;82m\]'
export BG_HL_HIGH='\[\e[48;2;82;79;103m\]'

RESET='\[\e[0m\]'
BOLD='\[\e[1m\]'

function branch_name {
	if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then
		text=$(git branch --show-current 2> /dev/null)
		echo -n " $text" 
	else
		echo ""
	fi
}

function set_git_color {
	# Get the status of the repo and chose a color accordingly
	color=""
	if [[ -z $(git status --porcelain) ]]; then
		color+=$PINE  # all changes commited and histories match
	fi
	if [[  $(git rev-list HEAD ^HEAD@{upstream} 2>/dev/null) ]]; then
		color+=$GOLD  # local and remote histories differ
	fi
	if [[ -n $(git status --porcelain) ]]; then
		color+=$LOVE  # there are uncommited local changes
	fi

	echo $color
}

function git_branch {
	if [[ -n "$(get_gitbranch)" ]]; then
		echo "$RESET$OVERLAY$(set_git_color)$BG_OVERLAY$(branch_name)$RESET$OVERLAY$RESET"
	else
		echo "" 
	fi
}

function update_prompt {
	PS1="$RESET$SUBTLE$BOLD\W $(git_branch)$RESET\n$GOLD$BOLD> $RESET"
}
PROMPT_COMMAND=update_prompt

# Make the script executable
chmod +x ~/.prompt.sh
