#!/bin/bash

#~ Fecha y hora del script
starttime=$(date)

#~ Creamos directorio de ser necesario
if [ ! -d "Thuja24" ]; then mkdir Thuja24; fi

#~ Ingresamos
cd Thuja24

#~ Setear lb config 
lb config --binary-images iso-hybrid --mode debian -d bookworm -a amd64 -k amd64 --linux-packages "linux-image linux-headers" --archive-areas "main contrib non-free non-free-firmware" --cache true --apt-recommends true --debian-installer live --debian-installer-gui true --win32-loader false --bootappend-live "boot=live components live-config.locales=es_ES.UTF-8 live-config.timezone=America/Argentina/Catamarca live-config.keyboard-layouts=latam live-config.user-default-groups=cdrom,floppy,audio,video,plugdev,netdev,dialout" --iso-application "Debian Bookworm" --iso-preparer "Thuja" --iso-publisher "Thuja" --image-name "Thuja" 

#~ Crea dir para setear calamares
if [ ! -d "config/includes.chroot/etc/calamares/modules" ]; then mkdir -p config/includes.chroot/etc/calamares/modules; fi

#~ Crea directorio para resguardar resultados para comparar.
if [ ! -d "config/includes.chroot/usr/share/hardinfo" ]; then mkdir -p config/includes.chroot/usr/share/hardinfo; fi

#~ Entradas típicas para crear Live Image.
echo "live-boot" > config/package-lists/live.list.chroot
echo "live-config" >> config/package-lists/live.list.chroot
echo "live-config-systemd" >> config/package-lists/live.list.chroot

#~ Asegurar de tener todos los paquetes grub que permiten bootear vía "bios" o "uefi".
echo grub-common grub2-common grub-pc-bin efibootmgr grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-signed grub-efi-ia32-bin libefiboot1 libefivar1 mokutil shim-helpers-amd64-signed shim-signed-common shim-unsigned > config/package-lists/grubuefi.list.binary

#~ Selección de paquetes...
if [ ! -f config/packages.lists/desktop.list.chroot ]; then
  echo "xfce4 \
  amd64-microcode \
  bash-completion \
  calamares \
  calamares-settings-debian \
  command-not-found \
  conky-all \
  curl \
  filezilla \
  firmware-linux \
  firmware-linux-free \
  firmware-linux-nonfree \
  firmware-misc-nonfree \
  galculator \
  geany \
  gparted \
  hardinfo \
  intel-microcode \
  inxi \
  lightdm \
  mc \
  meld \
  mpv \
  network-manager-gnome \
  openssh-client \
  rsync  \
  simplescreenrecorder \
  synaptic \
  terminator \
  wget \
  xfce4-goodies \
  xfce4-terminal" > config/package-lists/desktop.list.chroot
fi

#~ copiar resultados de hardinfo a la ubicación correcta.
cp ~/ThujaFiles/bm.conf.new config/includes.chroot/usr/share/hardinfo/benchmark.conf

#~ Copiar preferencias para Calamares.
#~ Añade groupos a preferencia y usuario al grupo sudo; también setea autologin y root password coincidente con usuarios.
cp -p ~/ThujaFiles/users.conf config/includes.chroot/etc/calamares/modules/

#~ Setea locale para el sistema installado AMERICA/Catamarca.
cp ~/ThujaFiles/locale.conf config/includes.chroot/etc/calamares/modules/

#~ Setea info del OS.
cp ~/ThujaFiles/lsb-release config/includes.chroot/etc/

#~ Crea la imagen.
sudo lb build

#~ Setear tiempo final para script.
endtime=$(date)

#~ Mostrar inicio y fin en terminal cuando todo termina.
echo "Script iniciado: $starttime"
echo "Script finalizado: $endtime"
