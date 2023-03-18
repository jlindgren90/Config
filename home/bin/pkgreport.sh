#!/bin/sh

if test -f pkgreport.txt ; then
  mv pkgreport.txt pkgreport.txt~
fi

printf "\n\n*** EXPLICITLY INSTALLED ***\n\n" >> pkgreport.txt
pacman -Qqett >> pkgreport.txt

printf "\n\n*** ORPHANED DEPENDENCIES ***\n\n" >> pkgreport.txt
pacman -Qqdtt >> pkgreport.txt

printf "\n\n*** AVAILABLE FROM AUR ***\n\n" >> pkgreport.txt
pacman -Qm | aur vercmp --all | cut -d' ' -f1 | tee pkgaur.txt >> pkgreport.txt

printf "\n\n*** INSTALLED LOCALLY ***\n\n" >> pkgreport.txt
pacman -Qqm > pkgunknown.txt
comm -23 pkgunknown.txt pkgaur.txt >> pkgreport.txt
rm pkgaur.txt

printf "\n\n*** OVERRIDDEN LOCALLY ***\n\n" >> pkgreport.txt
sed -n '/%NAME%/{n;h};/%VALIDATION%/{n;/none/{x;p}}' /var/lib/pacman/local/*/desc > pkgunsigned.txt
comm -23 pkgunsigned.txt pkgunknown.txt >> pkgreport.txt
rm pkgunsigned.txt pkgunknown.txt

printf "\n\n*** AUR UPGRADES AVAILABLE ***\n\n" >> pkgreport.txt
pacman -Qm | aur vercmp >> pkgreport.txt

if test -f pkgreport.txt~ ; then
  colordiff -u pkgreport.txt~ pkgreport.txt
fi
