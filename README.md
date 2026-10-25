# lkwr zsh theme

A powerline style zsh theme for oh-my-zsh, inspired by
[powerlevel10k](https://github.com/romkatv/powerlevel10k) and
[agnoster](https://github.com/agnoster/agnoster-zsh-theme).

```
 user@host  ~/git/project   main ⇡2 !1        2m 5s  ✘ 1  16:39:17
```

Left and right prompt sit on the same line as your cursor. Both outer edges are
flat (padded with the segment's own color); segments are joined with powerline
arrows (`U+E0B0` on the left, `U+E0B2` on the right).

## Requirements

- zsh with [oh-my-zsh](https://ohmyz.sh)
- A [Nerd Font](https://www.nerdfonts.com) set as your terminal font
- git 2.35 or newer for the git segment (older versions just hide it)

## Installation

```zsh
git clone https://github.com/lkwr/zsh-theme.git "$ZSH_CUSTOM/themes/lkwr"
```

Then in `~/.zshrc`:

```zsh
ZSH_THEME="lkwr/lkwr"
```

Open a new terminal or run `exec zsh`.

## Segments

**Left**

| Name      | Shows                                                                                                               |
| --------- | ------------------------------------------------------------------------------------------------------------------- |
| `context` | `user@host`. Turns red when you are root.                                                                           |
| `path`    | Current directory, with `~` for your home folder.                                                                   |
| `git`     | Branch (or short commit hash when detached) and status. Green when clean, yellow when dirty. Hidden outside a repo. |

Git status indicators:

| Icon | Meaning                     |
| ---- | --------------------------- |
| `⇣2` | 2 commits behind upstream   |
| `⇡2` | 2 commits ahead of upstream |
| `*2` | 2 stashes                   |
| `~2` | 2 merge conflicts           |
| `+2` | 2 staged changes            |
| `!2` | 2 unstaged changes          |
| `?2` | 2 untracked files           |

**Right**

| Name       | Shows                                                                                         |
| ---------- | --------------------------------------------------------------------------------------------- |
| `duration` | How long the last command took, e.g. `1h 2m 5s`. Hidden under 1 second.                       |
| `error`    | Exit code of the last command, only if not 0. Signals are shown by name (`✘ INT` for Ctrl+C). |
| `time`     | Current time, `HH:MM:SS` (24h) by default, see `LKWR_TIME_FORMAT`.                            |

## Configuration

Set any of these in `~/.zshrc`. They can go before or after
`source $ZSH/oh-my-zsh.sh` and are read every time the prompt is drawn.

### Choosing segments

Remove a segment from the list to disable it, or reorder them:

```zsh
LKWR_LEFT_SEGMENTS=(context path git)        # default
LKWR_RIGHT_SEGMENTS=(duration error time)    # default
```

### Behavior

| Setting                      | Default  | Description                                                                                           |
| ---------------------------- | -------- | ----------------------------------------------------------------------------------------------------- |
| `LKWR_CONTEXT_SHOW`          | `always` | `remote` shows `user@host` only over SSH or as root.                                                  |
| `LKWR_PATH_MAX_DIRS`         | `0`      | Show only the last N directories (`…/lkwr/lkwr-zsh`). `0` shows the full path.                        |
| `LKWR_DURATION_THRESHOLD`    | `1`      | Minimum seconds before the duration is shown.                                                         |
| `LKWR_DURATION_FORMAT`       | `human`  | `human` (`1h 2m 5s`) or `seconds` (`3725s`).                                                          |
| `LKWR_ERROR_SIGNAL_NAMES`    | `true`   | Show signal names (`INT`, `KILL`) instead of codes 129–159.                                           |
| `LKWR_TIME_FORMAT`           | `24h`    | `24h` (`16:39:17`), `12h` (`04:39:17 PM`), or any strftime format, e.g. `'%H:%M'`.                    |
| `LKWR_TIME_UPDATE_ON_EXEC`   | `true`   | Refresh the time when you press Enter, so the scrollback shows when each command started.             |
| `LKWR_TRANSIENT_PROMPT`      | `false`  | Only the current line shows segments; submitted lines are replaced with `LKWR_TRANSIENT_PROMPT_TEXT`. |
| `LKWR_TRANSIENT_PROMPT_TEXT` | `'❯ '`   | Prompt for submitted lines. Supports prompt escapes, e.g. `'%F{244}❯%f '`.                            |

### Colors

Every segment has a background (`_BG`) and foreground (`_FG`) color. Use color
names (`black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`)
or 256-color numbers (`0`–`255`).

| Setting                        | Default BG | Default FG |
| ------------------------------ | ---------- | ---------- |
| `LKWR_CONTEXT_BG` / `_FG`      | `black`    | `default`  |
| `LKWR_CONTEXT_ROOT_BG` / `_FG` | `black`    | `red`      |
| `LKWR_PATH_BG` / `_FG`         | `blue`     | `black`    |
| `LKWR_GIT_CLEAN_BG` / `_FG`    | `green`    | `black`    |
| `LKWR_GIT_DIRTY_BG` / `_FG`    | `yellow`   | `black`    |
| `LKWR_DURATION_BG` / `_FG`     | `black`    | `yellow`   |
| `LKWR_ERROR_BG` / `_FG`        | `red`      | `white`    |
| `LKWR_TIME_BG` / `_FG`         | `white`    | `black`    |

Two neighboring segments with the same background are joined with a thin
separator instead of a full arrow.

### Icons

| Setting                                   | Default             |
| ----------------------------------------- | ------------------- |
| `LKWR_SEP_LEFT` / `LKWR_SEP_LEFT_THIN`    | `U+E0B0` / `U+E0B1` |
| `LKWR_SEP_RIGHT` / `LKWR_SEP_RIGHT_THIN`  | `U+E0B2` / `U+E0B3` |
| `LKWR_ICON_BRANCH`                        | `U+E0A0`            |
| `LKWR_ICON_TIME`                          | `U+F017` (clock)    |
| `LKWR_ICON_ERROR`                         | `✘`                 |
| `LKWR_ICON_BEHIND` / `LKWR_ICON_AHEAD`    | `⇣` / `⇡`           |
| `LKWR_ICON_STASH`                         | `*`                 |
| `LKWR_ICON_CONFLICT`                      | `~`                 |
| `LKWR_ICON_STAGED` / `LKWR_ICON_UNSTAGED` | `+` / `!`           |
| `LKWR_ICON_UNTRACKED`                     | `?`                 |

Use `$'\uXXXX'` for Nerd Font glyphs, e.g. `LKWR_ICON_BRANCH=$''`.

### Example

```zsh
LKWR_LEFT_SEGMENTS=(context path git)
LKWR_CONTEXT_SHOW=remote
LKWR_PATH_MAX_DIRS=4
LKWR_PATH_BG=31 LKWR_PATH_FG=white
LKWR_TRANSIENT_PROMPT=true

ZSH_THEME="lkwr/lkwr"
source $ZSH/oh-my-zsh.sh
```

## Notes

- The right prompt keeps zsh's default 1-column gap to the terminal edge.
  `ZLE_RPROMPT_INDENT=0` in `.zshrc` makes it touch the edge, but old prompt
  lines then wrap and leave a mess when the terminal is made narrower.
- `LKWR_CONTEXT_SHOW=remote` detects SSH via `$SSH_CONNECTION`, `$SSH_CLIENT`
  and `$SSH_TTY`. Inside tmux these come from the shell that started the tmux
  server, so a session started locally and attached over SSH counts as local.
- If your home folder is a git repo (e.g. for dotfiles), the git segment shows
  in every folder below it.
