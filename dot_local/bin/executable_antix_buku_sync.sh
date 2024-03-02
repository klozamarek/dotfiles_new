#!/bin/sh
status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 ssserpent@antix echo ok 2>&1)
if [[ $status == ok ]] ; then
    # backup existing database in local directory
    cp /home/ssserpent/.config/local/share/buku/bookmarks.db /home/ssserpent/.config/local/share/buku/bookmarks.db_bak
    # pull operation
    rsync -avzu ssserpent@antix:/home/ssserpent/.config/local/share/buku/bookmarks.db /home/ssserpent/.config/local/share/buku/bookmarks.db
    # push operation
    rsync -avzu /home/ssserpent/.config/local/share/buku/bookmarks.db ssserpent@antix:/home/ssserpent/.config/local/share/buku/bookmarks.db
    # update timestamp on local database
    touch /home/ssserpent/.config/local/share/buku/bookmarks.db
    # backup existing database in local directory
    cp /home/ssserpent/Documents/mydirtynotes.txt /home/ssserpent/Documents/mydirtynotes.txt_bak
    # pull operation
    rsync -avzu ssserpent@antix:/home/ssserpent/Documents/mydirtynotes.txt /home/ssserpent/Documents/mydirtynotes.txt
    # push operation
    rsync -avzu /home/ssserpent/Documents/mydirtynotes.txt ssserpent@antix:/home/ssserpent/Documents/mydirtynotes.txt
    # update timestamp on local database
    touch /home/ssserpent/Documents/mydirtynotes.txt
  else
    echo "No connection to ssh server"
fi
