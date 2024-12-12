#!/bin/bash

# 默认参数
ROOT_DIR=$(pwd) # 默认根目录为当前运行目录
RECURSIVE=false # 默认不递归检查子目录

# ANSI 颜色代码
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_CYAN="\033[36m"
COLOR_GRAY="\033[90m"

# 解析参数
while getopts "sd:" opt; do
    case $opt in
    s) RECURSIVE=true ;;     # 设置递归检查
    d) ROOT_DIR="$OPTARG" ;; # 设置检查根目录
    *)
        echo -e "${COLOR_RED}Usage: $0 [-s] [-d root_directory]${COLOR_RESET}" >&2
        exit 1
        ;;
    esac
done

echo -e "${COLOR_CYAN}Checking directory:${COLOR_RESET} $ROOT_DIR"
echo -e "${COLOR_CYAN}Recursive check:${COLOR_RESET} $RECURSIVE"

# 初始化分类列表
no_git=()
local_only=()
clean=()
dirty=()
need_push=()
need_pull=()
conflicts=()

# 定义检查函数
check_git_repo() {
    local dir=$1
    if [ -d "$dir/.git" ]; then
        echo -e "${COLOR_BLUE}Checking Git repository:${COLOR_RESET} $dir"
        cd "$dir" || return

        # 检查是否有远程仓库
        remote_count=$(git remote | wc -l)
        if [ "$remote_count" -eq 0 ]; then
            echo -e "  ${COLOR_YELLOW}⚠️ Local-only Git repository (no remote)${COLOR_RESET}"
            local_only+=("$dir")
            cd "$ROOT_DIR" || exit
            return
        fi

        # 检查是否有未提交的更改
        if [ -n "$(git status --porcelain)" ]; then
            echo -e "  ${COLOR_RED}⚠️ Uncommitted changes${COLOR_RESET}"
            dirty+=("$dir")
        else
            # 检查是否与远程同步
            git remote update >/dev/null 2>&1
            LOCAL=$(git rev-parse @)
            REMOTE=$(git rev-parse @{u})
            BASE=$(git merge-base @ @{u})

            if [ "$LOCAL" = "$REMOTE" ]; then
                echo -e "  ${COLOR_GREEN}✅ Up-to-date with remote${COLOR_RESET}"
                clean+=("$dir")
            elif [ "$LOCAL" = "$BASE" ]; then
                echo -e "  ${COLOR_YELLOW}⚠️ Behind remote (pull needed)${COLOR_RESET}"
                need_pull+=("$dir")
            elif [ "$REMOTE" = "$BASE" ]; then
                echo -e "  ${COLOR_YELLOW}⚠️ Ahead of remote (push needed)${COLOR_RESET}"
                need_push+=("$dir")
            else
                echo -e "  ${COLOR_RED}⚠️ Diverged (conflicts with remote)${COLOR_RESET}"
                conflicts+=("$dir")
            fi
        fi

        cd "$ROOT_DIR" || exit
    else
        no_git+=("$dir")
    fi
}

# 遍历目录
if $RECURSIVE; then
    # 递归查找所有目录
    find "$ROOT_DIR" -type d | while read -r subdir; do
        check_git_repo "$subdir"
    done
else
    # 仅检查当前目录下的一级目录
    for dir in "$ROOT_DIR"/*; do
        [ -d "$dir" ] && check_git_repo "$dir"
    done
fi

# 分类汇总输出
echo ""
echo -e "${COLOR_CYAN}====== Summary ======${COLOR_RESET}"

echo -e "${COLOR_GRAY}[Directories without Git repository]:${COLOR_RESET}"
for item in "${no_git[@]}"; do echo -e "  ${COLOR_GRAY}- $item${COLOR_RESET}"; done

echo -e "\n${COLOR_YELLOW}[Local-only Git repositories (no remote)]:${COLOR_RESET}"
for item in "${local_only[@]}"; do echo -e "  ${COLOR_YELLOW}- $item${COLOR_RESET}"; done

echo -e "\n${COLOR_GREEN}[Clean and up-to-date repositories]:${COLOR_RESET}"
for item in "${clean[@]}"; do echo -e "  ${COLOR_GREEN}- $item${COLOR_RESET}"; done

echo -e "\n${COLOR_RED}[Repositories with uncommitted changes]:${COLOR_RESET}"
for item in "${dirty[@]}"; do echo -e "  ${COLOR_RED}- $item${COLOR_RESET}"; done

echo -e "\n${COLOR_YELLOW}[Repositories that need to pull updates]:${COLOR_RESET}"
for item in "${need_pull[@]}"; do echo -e "  ${COLOR_YELLOW}- $item${COLOR_RESET}"; done

echo -e "\n${COLOR_YELLOW}[Repositories that need to push changes]:${COLOR_RESET}"
for item in "${need_push[@]}"; do echo -e "  ${COLOR_YELLOW}- $item${COLOR_RESET}"; done

echo -e "\n${COLOR_RED}[Repositories with conflicts]:${COLOR_RESET}"
for item in "${conflicts[@]}"; do echo -e "  ${COLOR_RED}- $item${COLOR_RESET}"; done
