# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  #source /usr/share/zsh/manjaro-zsh-prompt
fi

# mods last updated by JRS 6/13/2024
ZSH_THEME=agnoster
export PATH="$PATH:/home/jsmith/.local/bin"

function auto_pipenv_shell {
    if [ ! -n "${PIPENV_ACTIVE+1}" ]; then
        if [ -f "Pipfile" ] ; then
            pipenv shell
        fi
    fi
}

function cd {
    builtin cd "$@"
    auto_pipenv_shell
}

alias prp="pipenv run python3"
alias ldown="$HOME/.sh/literotica-yad.sh &; disown; exit"
alias sw="$HOME/.sh/weather.sh"
sw
# mods by JRS, end
