# Vraag de gebruiker om de installatie-schijf
echo "Enter the installation disk (e.g. /dev/sda):"
read disk

# Partitioneren van de schijf
parted $disk mklabel gpt
parted $disk mkpart primary 1MiB 513MiB
parted $disk set 1 boot on
parted $disk mkpart primary 513MiB 100%

# Formatteer de partities
mkfs.vfat -F32 ${disk}1
mkfs.btrfs ${disk}2

# Mount de partities
mount ${disk}2 /mnt
mkdir /mnt/boot
mount ${disk}1 /mnt/boot

# Maak subvolumes aan voor snapper
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt
# Mount de subvolumes met zstd3 compressie
mount -o subvol=@,compress=zstd ${disk}2 /mnt
mkdir /mnt/home
mount -o subvol=@home,compress=zstd ${disk}2  /mnt/home
mkdir /mnt/.snapshots
mount -o subvol=@snapshots ${disk}2  /mnt/.snapshots

# Installeer de basis-arch pakketten
pacstrap /mnt base linux btrfs-progs snapper
# Genereer fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Schrijf het script om te configueren

cat `oaicite:{"index":0,"invalid_reason":"Malformed citation << EOF > /mnt/root/configure.sh\n#!/bin/bash\n\n# Configureer de tijdzone\nln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime\nhwclock --systohc\n\n# Configureer de taal\necho \"en_US.UTF-8 UTF-8\" >> /etc/locale.gen\nlocale-gen\necho \"LANG=en_US.UTF-8\" > /etc/locale.conf\n\n# Configureer het netwerk\necho \"hostname\" > /etc/hostname\necho \"127.0.0.1 localhost\" >> /etc/hosts\necho \"::1 localhost\" >> /etc/hosts\necho \"127.0.0.1 hostname.localdomain hostname\" >>"}` /etc/hosts

# Stel root wachtwoord in
passwd

# Installeer grub bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub
grub-mkconfig -o /boot/grub/grub.cfg

# Maak de gebruiker Simon aan
useradd -m -G wheel -s /bin/bash simon
passwd simon

# Configureer snapper
snapper -c root create-config /
snapper -c home create-config /home
exitread -p "Wilt u het systeem herstarten? (j/n) " keuze
if [ "$keuze" = "j" ]; then
sudo reboot
elif [ "$keuze" = "n" ]; then
echo "Herstart geannuleerd."
else
echo "Ongeldige invoer. Voer alstublieft j of n in."

