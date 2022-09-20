#!/bin/sh

if test -f pkgreport.txt ; then
  mv pkgreport.txt pkgreport.txt~
fi

printf "\n\n*** EXPLICITLY INSTALLED ***\n\n" >> pkgreport.txt
pacman -Qqett >> pkgreport.txt

printf "\n\n*** ORPHANED DEPENDENCIES ***\n\n" >> pkgreport.txt
pacman -Qqdtt >> pkgreport.txt

printf "\n\n*** NOT IN OFFICIAL REPOS ***\n\n" >> pkgreport.txt
pacman -Qqm | tee pkgunknown.txt >> pkgreport.txt

printf "\n\n*** LOCAL OVERRIDES ***\n\n" >> pkgreport.txt
sed -n '/%NAME%/{n;h};/%VALIDATION%/{n;/none/{x;p}}' /var/lib/pacman/local/*/desc > pkgunsigned.txt
comm -23 pkgunsigned.txt pkgunknown.txt >> pkgreport.txt
rm pkgunsigned.txt pkgunknown.txt

printf "\n\n*** AUR UPGRADES AVAILABLE ***\n\n" >> pkgreport.txt
pacman -Qm | aur vercmp >> pkgreport.txt

if test -f pkgreport.txt~ ; then
  colordiff -u pkgreport.txt~ pkgreport.txt
fi
