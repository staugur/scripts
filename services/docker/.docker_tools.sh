#!/bin/bash
#Someone Author:www.saintic.com
#something tools for docker

alias docker-pid="sudo docker inspect --format '{{.State.Pid}}'"
alias docker-ip="sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

function docker-enter() {
    if [ -e $(dirname "$0")/nsenter ]; then
        # with boot2docker, nsenter is not in the PATH but it is in the same folder
        NSENTER=$(dirname "$0")/nsenter
    else
        NSENTER=nsenter
    fi
    [ -z "$NSENTER" ] && echo "WARN Cannot find nsenter" && return

    if [ -z "$1" ]; then
        echo "Usage: `basename "$0"` CONTAINER [COMMAND [ARG]...]"
        echo ""
        echo "Enters the Docker CONTAINER and executes the specified COMMAND."
        echo "If COMMAND is not specified, runs an interactive shell in CONTAINER."
    else
        PID=$(sudo docker inspect --format "{{.State.Pid}}" "$1")
        if [ -z "$PID" ]; then
            echo "WARN Cannot find the given container"
            return
        fi
        shift

        OPTS="--target $PID --mount --uts --ipc --net --pid"

        if [ -z "$1" ]; then
            # No command given.
            # Use su to clear all host environment variables except for TERM,
            # initialize the environment variables HOME, SHELL, USER, LOGNAME, PATH,
            # and start a login shell.
            #sudo $NSENTER "$OPTS" su - root
            sudo $NSENTER --target $PID --mount --uts --ipc --net --pid su - root
        else
            # Use env to clear all host environment variables.
            sudo $NSENTER --target $PID --mount --uts --ipc --net --pid env -i $@
        fi
    fi
}

rpm -q bridge-utils &> /dev/null  || yum -y install bridge-utils 
function docker-net() {
if [ "$#" -gt 2 ]; then
  pid=`docker-pid $1`
  mkdir -p /var/run/netns/
  ln -s /proc/${pid}/ns/net /var/run/netns/${pid}
  ip link add ${pid}_A type veth peer name ${pid}_B
  brctl addif br0 ${pid}_A
  ip link set ${pid}_A up
  ip link set ${pid}_B netns $pid
  ip netns exec $pid ip link set dev ${pid}_B name eth0
  ip netns exec $pid ip link set eth0 up
  ip netns exec $pid ip addr add $2 dev eth0
  ip netns exec $pid ip route add default via $3
else
  echo "docker-net ContainerID ContainerIP/MASK GATEWAY"
fi
}

