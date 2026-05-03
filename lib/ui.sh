#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  UI Library — DevForge macOS Setup
#  Terminal UI primitives: colors, boxes, spinners, progress bars
# ─────────────────────────────────────────────────────────────────

# ── ANSI Colors & Styles ──────────────────────────────────────────
export RESET='\033[0m'
export BOLD='\033[1m'
export DIM='\033[2m'
export ITALIC='\033[3m'
export UNDERLINE='\033[4m'

# Palette — Deep Space Dark
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[0;37m'
export GRAY='\033[0;90m'

export BRED='\033[1;31m'
export BGREEN='\033[1;32m'
export BYELLOW='\033[1;33m'
export BBLUE='\033[1;34m'
export BMAGENTA='\033[1;35m'
export BCYAN='\033[1;36m'
export BWHITE='\033[1;37m'

# Accent colors (256-color)
export ACCENT='\033[38;5;87m'      # Electric cyan
export ACCENT2='\033[38;5;213m'    # Soft magenta
export ACCENT3='\033[38;5;220m'    # Golden amber
export MUTED='\033[38;5;244m'      # Mid gray
export SUBTLE='\033[38;5;238m'     # Dark gray
export SUCCESS='\033[38;5;114m'    # Soft green
export WARNING='\033[38;5;215m'    # Amber
export ERROR='\033[38;5;196m'      # Red
export INFO='\033[38;5;75m'        # Sky blue

# Background
export BG_DARK='\033[48;5;234m'
export BG_ACCENT='\033[48;5;87m'

# ── Symbols ───────────────────────────────────────────────────────
SYM_CHECK="✓"
SYM_CROSS="✗"
SYM_ARROW="→"
SYM_DOT="•"
SYM_STAR="★"
SYM_DIAMOND="◆"
SYM_LINE="─"
SYM_PIPE="│"
SYM_CORNER_TL="╭"
SYM_CORNER_TR="╮"
SYM_CORNER_BL="╰"
SYM_CORNER_BR="╯"
SYM_TEE_L="├"
SYM_TEE_R="┤"

# Terminal width
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

# ── Core print functions ──────────────────────────────────────────
ui_echo() { printf "${1}${RESET}\n"; }

ui_print() {
  local color="${1}" icon="${2}" msg="${3}"
  printf "  ${color}${icon}${RESET}  ${msg}\n"
}

ui_success() { ui_print "${SUCCESS}" "${SYM_CHECK}" "${BGREEN}${1}${RESET}"; }
ui_error()   { ui_print "${ERROR}"   "${SYM_CROSS}" "${BRED}${1}${RESET}"; }
ui_warn()    { ui_print "${WARNING}" "!" "${BYELLOW}${1}${RESET}"; }
ui_info()    { ui_print "${INFO}"    "${SYM_ARROW}" "${WHITE}${1}${RESET}"; }
ui_step()    { ui_print "${ACCENT}"  "${SYM_DIAMOND}" "${ACCENT}${BOLD}${1}${RESET}"; }
ui_dim()     { ui_print "${MUTED}"   "${SYM_DOT}" "${MUTED}${1}${RESET}"; }

# ── Horizontal rule ───────────────────────────────────────────────
ui_rule() {
  local char="${1:-─}" color="${2:-$SUBTLE}"
  local line=""
  for ((i=0; i<TERM_WIDTH-2; i++)); do line+="${char}"; done
  printf "  ${color}${line}${RESET}\n"
}

ui_rule_accent() {
  local line=""
  for ((i=0; i<TERM_WIDTH-2; i++)); do line+="─"; done
  printf "  ${ACCENT}${line}${RESET}\n"
}

# ── Blank line ────────────────────────────────────────────────────
ui_gap() { echo ""; }

# ── Bordered box ──────────────────────────────────────────────────
ui_box() {
  local title="${1}" color="${2:-$ACCENT}"
  local inner=$((TERM_WIDTH - 4))
  local title_len=${#title}
  local pad=$(( (inner - title_len - 2) / 2 ))
  local right_pad=$(( inner - title_len - 2 - pad ))

  local top_line="${SYM_CORNER_TL}"
  local bot_line="${SYM_CORNER_BL}"
  for ((i=0; i<inner; i++)); do top_line+="─"; bot_line+="─"; done
  top_line+="${SYM_CORNER_TR}"
  bot_line+="${SYM_CORNER_BR}"

  local pad_left="" pad_right=""
  for ((i=0; i<pad; i++)); do pad_left+=" "; done
  for ((i=0; i<right_pad; i++)); do pad_right+=" "; done

  ui_gap
  printf "  ${color}${top_line}${RESET}\n"
  printf "  ${color}${SYM_PIPE}${RESET}${pad_left} ${BOLD}${BWHITE}${title}${RESET}${pad_right} ${color}${SYM_PIPE}${RESET}\n"
  printf "  ${color}${bot_line}${RESET}\n"
  ui_gap
}

# ── Section header ────────────────────────────────────────────────
ui_section() {
  local title="${1}" icon="${2:-◆}"
  ui_gap
  printf "  ${ACCENT}${icon} ${BOLD}${BWHITE}${title}${RESET}\n"
  printf "  ${SUBTLE}"
  for ((i=0; i<${#title}+4; i++)); do printf "─"; done
  printf "${RESET}\n"
  ui_gap
}

# ── Spinner ───────────────────────────────────────────────────────
SPINNER_PID=""
SPINNER_FRAMES=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

ui_spinner_start() {
  local msg="${1}"
  (
    local i=0
    while true; do
      printf "\r  ${ACCENT}${SPINNER_FRAMES[$((i % ${#SPINNER_FRAMES[@]}))]}${RESET}  ${MUTED}${msg}${RESET}   "
      sleep 0.08
      ((i++))
    done
  ) &
  SPINNER_PID=$!
  disown "$SPINNER_PID" 2>/dev/null
}

ui_spinner_stop() {
  if [[ -n "$SPINNER_PID" ]]; then
    kill "$SPINNER_PID" 2>/dev/null
    wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
    printf "\r\033[K"
  fi
}

ui_spinner_done() {
  local msg="${1}"
  ui_spinner_stop
  ui_success "${msg}"
}

ui_spinner_fail() {
  local msg="${1}"
  ui_spinner_stop
  ui_error "${msg}"
}

# ── Progress bar ──────────────────────────────────────────────────
ui_progress() {
  local current="${1}" total="${2}" label="${3:-Progress}"
  local pct=$(( current * 100 / total ))
  local bar_width=$(( TERM_WIDTH - 20 ))
  local filled=$(( pct * bar_width / 100 ))
  local empty=$(( bar_width - filled ))

  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done

  printf "\r  ${MUTED}${label}${RESET}  ${ACCENT}${bar}${RESET}  ${BOLD}${pct}%%${RESET}  "
}

ui_progress_done() {
  printf "\n"
}

# ── Prompt ────────────────────────────────────────────────────────
ui_prompt() {
  local question="${1}" default="${2}"
  local prompt_str
  if [[ -n "$default" ]]; then
    prompt_str="  ${ACCENT}?${RESET}  ${BWHITE}${question}${RESET} ${MUTED}[${default}]${RESET}: "
  else
    prompt_str="  ${ACCENT}?${RESET}  ${BWHITE}${question}${RESET}: "
  fi
  printf "${prompt_str}"
  read -r REPLY
  if [[ -z "$REPLY" && -n "$default" ]]; then
    REPLY="$default"
  fi
}

ui_confirm() {
  local question="${1}" default="${2:-y}"
  local opts
  if [[ "$default" == "y" ]]; then opts="${BGREEN}Y${RESET}${MUTED}/n${RESET}"; else opts="${MUTED}y/${RESET}${BRED}N${RESET}"; fi
  printf "  ${ACCENT}?${RESET}  ${BWHITE}${question}${RESET} ${MUTED}[${RESET}${opts}${MUTED}]${RESET} "
  read -r REPLY
  REPLY="${REPLY:-$default}"
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

# ── Menu ──────────────────────────────────────────────────────────
ui_menu() {
  local title="${1}"; shift
  local options=("$@")
  ui_gap
  printf "  ${ACCENT}${BOLD}${title}${RESET}\n"
  ui_gap
  for i in "${!options[@]}"; do
    printf "    ${ACCENT}$(( i + 1 ))${RESET}  ${WHITE}${options[$i]}${RESET}\n"
  done
  ui_gap
  printf "  ${ACCENT}›${RESET}  "
  read -r MENU_CHOICE
}

# ── Status badge ──────────────────────────────────────────────────
ui_badge() {
  local text="${1}" color="${2:-$ACCENT}"
  printf "${color}[${BOLD}${text}${RESET}${color}]${RESET}"
}

# ── Key-Value pair ────────────────────────────────────────────────
ui_kv() {
  local key="${1}" val="${2}"
  printf "  ${MUTED}${key}${RESET}  ${ACCENT}${SYM_ARROW}${RESET}  ${BWHITE}${val}${RESET}\n"
}

# ── Clear screen with branding ────────────────────────────────────
ui_clear() {
  clear
}

# ── Log to file ───────────────────────────────────────────────────
# NOTA: LOG_FILE y ui_log() están definidos en utils.sh (fuente única
# de verdad). Esta sección se eliminó para evitar definiciones duplicadas
# que producían un archivo de log distinto cada vez que se sourceaba.
