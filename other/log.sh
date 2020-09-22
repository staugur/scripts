#!/bin/bash
#Author:      staugur
#Version:     0.1
#Description: 公共函数
#CreateTime:  2019-08-05
#License:     BSD 3-Clause
#Copyright:   (c) 2019 by staugur.

_log() {
    #: log函数可以接收两个环境变量
    #: RTFD_LOGLEVEL - 设置日志级别，默认0，debug:0; info:1; warn:2; error:3
    #: RTFD_LOGFILE - 设置日志记录的文件，默认程序下logs目录
    local SHELL_DIR="$(
        cd $(dirname "$0")
        pwd
    )"
    local LOG_DIR="${SHELL_DIR}/../logs"
    local loglevel=${RTFD_LOGLEVEL:-0}
    local logfile=${RTFD_LOGFILE:-"${LOG_DIR}/sys.log"}
    [[ -z "${RTFD_LOGFILE}" && ! -d $LOG_DIR ]] && mkdir $LOG_DIR
    local msg
    local logtype=$1
    shift
    msg="$@"
    datetime=$(date +'%F %H:%M:%S')
    #使用内置变量$LINENO不行，不能显示调用那一行行号，改用caller
    logformat="[ ${logtype^^} ]\t${datetime}\t${BASH_SOURCE[-1]}:$(caller 1 | awk '{print$1}')\t${msg}"
    {
        case $logtype in
        debug)
            [[ $loglevel -le 0 ]] && echo -e "\033[34m${logformat}\033[0m"
            ;;
        info)
            [[ $loglevel -le 1 ]] && echo -e "\033[32m${logformat}\033[0m"
            ;;
        warn)
            [[ $loglevel -le 2 ]] && echo -e "\033[33m${logformat}\033[0m"
            ;;
        error)
            [[ $loglevel -le 3 ]] && echo -e "\033[31m${logformat}\033[0m"
            ;;
        esac
    } | tee -a $logfile
    return $?
}

debug() {
    _log "debug" "$@"
}

info() {
    _log "info" "$@"
}

warn() {
    _log "warn" "$@"
}

error() {
    _log "error" "$@"
}

check_env() {
    local c=$1
    if [ -z "${c}" ]; then
        printf "Not found env named ${c}"
        return 127
    fi
}

check_exit_env() {
    local c=$1
    if [ -z "${c}" ]; then
        printf "Not found env named ${c}"
        exit 127
    fi
}
