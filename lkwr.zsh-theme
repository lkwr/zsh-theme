# lkwr.zsh-theme - powerline style prompt, inspired by powerlevel10k and agnoster.
# Requires a NerdFont. All LKWR_* settings can be set in .zshrc (before or after
# oh-my-zsh is sourced) and are read every time the prompt is drawn.

setopt prompt_subst
autoload -Uz add-zsh-hook
zmodload zsh/datetime

# --- Segments --------------------------------------------------------------
# Remove a segment from the list to disable it.
(( ${+LKWR_LEFT_SEGMENTS} ))  || typeset -ga LKWR_LEFT_SEGMENTS=(context path git)
(( ${+LKWR_RIGHT_SEGMENTS} )) || typeset -ga LKWR_RIGHT_SEGMENTS=(duration error time)

# --- Colors (names like "blue" or 256-color numbers like "31") ---------------
: ${LKWR_CONTEXT_BG:=black}     ${LKWR_CONTEXT_FG:=default}
: ${LKWR_CONTEXT_ROOT_BG:=black} ${LKWR_CONTEXT_ROOT_FG:=red}   # used when root
: ${LKWR_PATH_BG:=blue}         ${LKWR_PATH_FG:=black}
: ${LKWR_GIT_CLEAN_BG:=green}   ${LKWR_GIT_CLEAN_FG:=black}
: ${LKWR_GIT_DIRTY_BG:=yellow}  ${LKWR_GIT_DIRTY_FG:=black}
: ${LKWR_DURATION_BG:=black}    ${LKWR_DURATION_FG:=yellow}
: ${LKWR_ERROR_BG:=red}         ${LKWR_ERROR_FG:=white}
: ${LKWR_TIME_BG:=white}        ${LKWR_TIME_FG:=black}

# --- Icons -------------------------------------------------------------------
: ${LKWR_SEP_LEFT:=$''}       ${LKWR_SEP_LEFT_THIN:=$''}
: ${LKWR_SEP_RIGHT:=$''}      ${LKWR_SEP_RIGHT_THIN:=$''}
: ${LKWR_ICON_BRANCH:=$''}
: ${LKWR_ICON_BEHIND:=⇣}            ${LKWR_ICON_AHEAD:=⇡}
: ${LKWR_ICON_STASH:=*}             ${LKWR_ICON_CONFLICT:=~}
: ${LKWR_ICON_STAGED:=+}            ${LKWR_ICON_UNSTAGED:=!}
: ${LKWR_ICON_UNTRACKED:=?}
: ${LKWR_ICON_TIME:=$''}      ${LKWR_ICON_ERROR:=✘}

# --- Other -------------------------------------------------------------------
: ${LKWR_DURATION_THRESHOLD:=1}   # seconds; shorter commands show no duration
: ${LKWR_DURATION_FORMAT:=human}  # human (1h 2m 5s) or seconds (3725s)
: ${LKWR_CONTEXT_SHOW:=always}    # always, or remote (only over SSH or as root)
: ${LKWR_PATH_MAX_DIRS:=0}       # >0 shows only the last N dirs (…/c/d); 0 = full path
: ${LKWR_ERROR_SIGNAL_NAMES:=true} # show INT instead of 130 for signal exits
: ${LKWR_TIME_FORMAT:=24h}        # 24h, 12h, or any strftime format like '%H:%M'
: ${LKWR_TIME_UPDATE_ON_EXEC:=true} # refresh the time when a command is submitted
: ${LKWR_TRANSIENT_PROMPT:=false}  # true: only the current line shows segments
: ${LKWR_TRANSIENT_PROMPT_TEXT:='❯ '} # what submitted lines show instead (prompt escapes ok)

# --- Segment functions ---------------------------------------------------------
# Each one calls _lkwr_add <bg> <fg> <text>, or adds nothing to hide itself.
# Text is prompt-expanded, so % in dynamic values must be escaped as %%.

_lkwr_add() {
  _lkwr_bgs+=("$1") _lkwr_fgs+=("$2") _lkwr_txts+=("$3")
}

_lkwr_seg_context() {
  if [[ $LKWR_CONTEXT_SHOW == remote ]] && (( EUID != 0 )) &&
     [[ -z $SSH_CONNECTION && -z $SSH_CLIENT && -z $SSH_TTY ]]; then
    return
  fi
  if (( EUID == 0 )); then
    _lkwr_add $LKWR_CONTEXT_ROOT_BG $LKWR_CONTEXT_ROOT_FG '%n@%m'
  else
    _lkwr_add $LKWR_CONTEXT_BG $LKWR_CONTEXT_FG '%n@%m'
  fi
}

_lkwr_seg_path() {
  local -i n=$LKWR_PATH_MAX_DIRS
  if (( n > 0 )); then
    # %(N~|a|b): a if the path has at least N elements, else b
    _lkwr_add $LKWR_PATH_BG $LKWR_PATH_FG "%($(( n + 1 ))~|…/%${n}~|%~)"
  else
    _lkwr_add $LKWR_PATH_BG $LKWR_PATH_FG '%~'
  fi
}

_lkwr_seg_git() {
  (( $+commands[git] )) || return
  local out line head oid
  local -i ahead=0 behind=0 stash=0 conflicts=0 staged=0 unstaged=0 untracked=0
  out=$(command git status --porcelain=v2 --branch --show-stash 2>/dev/null) || return

  for line in ${(f)out}; do
    case $line in
      ('# branch.oid '*)  oid=${line#\# branch.oid } ;;
      ('# branch.head '*) head=${line#\# branch.head } ;;
      ('# branch.ab '*)   local -a ab=(${=line#\# branch.ab })
                          ahead=${ab[1]#+} behind=${ab[2]#-} ;;
      ('# stash '*)       stash=${line#\# stash } ;;
      ([12]' '*)          [[ ${line[3]} != . ]] && (( staged++ ))
                          [[ ${line[4]} != . ]] && (( unstaged++ )) ;;
      ('u '*)             (( conflicts++ )) ;;
      ('? '*)             (( untracked++ )) ;;
    esac
  done

  [[ $head == '(detached)' ]] && head=${oid[1,8]}
  local txt="$LKWR_ICON_BRANCH ${head//\%/%%}"
  (( behind ))    && txt+=" $LKWR_ICON_BEHIND$behind"
  (( ahead ))     && txt+=" $LKWR_ICON_AHEAD$ahead"
  (( stash ))     && txt+=" $LKWR_ICON_STASH$stash"
  (( conflicts )) && txt+=" $LKWR_ICON_CONFLICT$conflicts"
  (( staged ))    && txt+=" $LKWR_ICON_STAGED$staged"
  (( unstaged ))  && txt+=" $LKWR_ICON_UNSTAGED$unstaged"
  (( untracked )) && txt+=" $LKWR_ICON_UNTRACKED$untracked"

  if (( conflicts + staged + unstaged + untracked )); then
    _lkwr_add $LKWR_GIT_DIRTY_BG $LKWR_GIT_DIRTY_FG "$txt"
  else
    _lkwr_add $LKWR_GIT_CLEAN_BG $LKWR_GIT_CLEAN_FG "$txt"
  fi
}

_lkwr_seg_duration() {
  local -i secs=$_lkwr_duration
  (( secs >= LKWR_DURATION_THRESHOLD )) || return
  local txt
  if [[ $LKWR_DURATION_FORMAT == human ]]; then
    (( secs >= 3600 )) && txt+="$(( secs / 3600 ))h "
    (( secs >= 60 ))   && txt+="$(( secs % 3600 / 60 ))m "
    txt+="$(( secs % 60 ))s"
  else
    txt="${secs}s"
  fi
  _lkwr_add $LKWR_DURATION_BG $LKWR_DURATION_FG "$LKWR_ICON_TIME $txt"
}

_lkwr_seg_error() {
  (( _lkwr_status )) || return
  local code=$_lkwr_status
  # Exit codes 129-159 mean "killed by signal N-128"; $signals[1] is EXIT.
  if [[ $LKWR_ERROR_SIGNAL_NAMES == true ]] && (( code > 128 && code <= 128 + 31 )); then
    code=${signals[code - 127]}
  fi
  _lkwr_add $LKWR_ERROR_BG $LKWR_ERROR_FG "$LKWR_ICON_ERROR $code"
}

_lkwr_seg_time() {
  local fmt
  case $LKWR_TIME_FORMAT in
    (24h) fmt='%H:%M:%S' ;;
    (12h) fmt='%I:%M:%S %p' ;;
    (*)   fmt=$LKWR_TIME_FORMAT ;;
  esac
  _lkwr_add $LKWR_TIME_BG $LKWR_TIME_FG "%D{$fmt}"
}

# --- Rendering ---------------------------------------------------------------
# The outer edges are flat: the first left / last right segment just starts or
# ends with a padding space in its own color.

_lkwr_collect() {
  _lkwr_bgs=() _lkwr_fgs=() _lkwr_txts=()
  local seg
  for seg in "$@"; do
    (( $+functions[_lkwr_seg_$seg] )) && _lkwr_seg_$seg
  done
}

_lkwr_render_left() {
  _lkwr_collect $LKWR_LEFT_SEGMENTS
  local out= i
  for (( i = 1; i <= $#_lkwr_bgs; i++ )); do
    if (( i == 1 )); then
      out+="%K{$_lkwr_bgs[i]}"
    elif [[ $_lkwr_bgs[i] == $_lkwr_bgs[i-1] ]]; then
      out+="%F{$_lkwr_fgs[i]}$LKWR_SEP_LEFT_THIN"
    else
      out+="%K{$_lkwr_bgs[i]}%F{$_lkwr_bgs[i-1]}$LKWR_SEP_LEFT"
    fi
    out+="%F{$_lkwr_fgs[i]} $_lkwr_txts[i] "
  done
  (( $#_lkwr_bgs )) && out+="%k%F{$_lkwr_bgs[-1]}$LKWR_SEP_LEFT%f "
  _lkwr_left=$out
}

_lkwr_render_right() {
  _lkwr_collect $LKWR_RIGHT_SEGMENTS
  local out= i
  for (( i = 1; i <= $#_lkwr_bgs; i++ )); do
    if (( i > 1 )) && [[ $_lkwr_bgs[i] == $_lkwr_bgs[i-1] ]]; then
      out+="%F{$_lkwr_fgs[i]}$LKWR_SEP_RIGHT_THIN"
    else
      out+="%F{$_lkwr_bgs[i]}$LKWR_SEP_RIGHT"
    fi
    out+="%K{$_lkwr_bgs[i]}%F{$_lkwr_fgs[i]} $_lkwr_txts[i] "
  done
  (( $#_lkwr_bgs )) && out+="%k%f"
  _lkwr_right=$out
}

# --- Hooks -------------------------------------------------------------------

typeset -g  _lkwr_left _lkwr_right
typeset -gi _lkwr_status
typeset -gF _lkwr_start _lkwr_duration
typeset -ga _lkwr_bgs _lkwr_fgs _lkwr_txts

_lkwr_preexec() {
  _lkwr_start=$EPOCHREALTIME
}

_lkwr_precmd() {
  _lkwr_status=$?
  if (( _lkwr_start )); then
    (( _lkwr_duration = EPOCHREALTIME - _lkwr_start ))
    _lkwr_start=0
  else
    _lkwr_duration=0   # empty command line, nothing ran
  fi
  _lkwr_render_left
  _lkwr_render_right
}

# Redraw the prompt when Enter is pressed: either replace it with the short
# transient prompt, or refresh the time so the scrollback shows when the
# command started. precmd renders the full prompt again for the next line.
_lkwr_line_finish() {
  if [[ $LKWR_TRANSIENT_PROMPT == true ]]; then
    _lkwr_left=$LKWR_TRANSIENT_PROMPT_TEXT _lkwr_right=
    zle .reset-prompt
    return
  fi
  [[ $LKWR_TIME_UPDATE_ON_EXEC == true ]] || return
  (( ${LKWR_RIGHT_SEGMENTS[(Ie)time]} || ${LKWR_LEFT_SEGMENTS[(Ie)time]} )) || return
  zle .reset-prompt
}

add-zsh-hook preexec _lkwr_preexec
autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-finish _lkwr_line_finish
# Run first so $? is still the status of the user's command.
precmd_functions=(_lkwr_precmd ${precmd_functions:#_lkwr_precmd})

# The prompt only references the variables, so branch names etc. are never
# evaluated as code under prompt_subst.
PROMPT='${_lkwr_left}'
RPROMPT='${_lkwr_right}'
