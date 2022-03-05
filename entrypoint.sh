#!/bin/bash

pipe=/tmp/tmod.out
players=/tmp/tmod.players.out

function shutdown() {
  [ -n "$TMOD_SHUTDOWN_MSG" ] && inject "say $TMOD_SHUTDOWN_MSG"
  inject "exit"
  tmuxPid=$(pgrep tmux)
  tmodPid=$(pgrep --parent $tmuxPid Main)
  while [ -e /proc/$tmodPid ]; do
    sleep .5
  done
  rm $pipe
}

LD_LIBRARY_PATH="$LD_LIBRARY_PATH:lib:lib64"

server="mono --server --gc=sgen -O=all tModLoaderServer.exe"

if [ "$1" = "setup" ]; then
  $server
else
  trap shutdown SIGTERM SIGINT

  saveMsg='Autosave - $(date +"%Y-%m-%d %T")'
  
  if [ ! -z "$TMOD_AUTOSAVE_INTERVAL" ] && ! crontab -l | grep -q "Autosave"; then
    (crontab -l 2>/dev/null; echo "$TMOD_AUTOSAVE_INTERVAL echo \"$saveMsg\" > $pipe && inject save") | crontab -
  fi

  mkfifo $pipe
  tmux new-session -d "$server -config /terraria/config.txt | tee $pipe $players" &
  sleep 60 && /usr/sbin/crond -d 8 &
  cat $pipe &

  wait ${!}
fi