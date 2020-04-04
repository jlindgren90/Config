#!/bin/sh

for f in `find home -type f` ; do
    f1="${HOME}/${f#home/}"
    f2="${HOME}/.${f#home/}"
    if test -f "$f1" ; then
        cp "$f1" "$f"
    elif test -f "$f2" ; then
        cp "$f2" "$f"
    else
        echo "$f: no installed version found"
    fi
done
