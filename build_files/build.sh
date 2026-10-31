#!/bin/bash
# Sistema leve: Fedora bootc + XFCE, pensado para rodar em quase qualquer PC/notebook.
set -ouex pipefail

# ---------- Opções ----------
ENABLE_PRINTING=false   # troque para true para incluir suporte a impressoras (CUPS)

# Copia o conteúdo de system_files/ para /
cp -avf "/ctx/system_files"/. /

# ---------- 1. Firmware e microcode (compatibilidade de hardware) ----------
# (instalado com as dependências padrão para garantir todos os firmwares de Wi-Fi, vídeo e áudio)
dnf5 -y install linux-firmware microcode_ctl

# ---------- 2. Vídeo e entrada (X11 + drivers livres: Intel, AMD, NVIDIA/nouveau, VMs) ----------
dnf5 -y install --setopt=install_weak_deps=False \
    xorg-x11-server-Xorg xorg-x11-drv-libinput mesa-dri-drivers

# ---------- 3. Desktop XFCE (grupo mínimo "xfce-desktop": sessão, painel, Thunar, terminal, LightDM) ----------
dnf5 -y group install --setopt=install_weak_deps=False xfce-desktop

# Apps e integrações essenciais (sem pacotes de sobra)
dnf5 -y install --setopt=install_weak_deps=False --skip-unavailable \
    network-manager-applet NetworkManager-wifi \
    xfce4-pulseaudio-plugin xfce4-power-manager xfce4-notifyd \
    xfce4-screenshooter xfce4-taskmanager \
    Thunar thunar-volman thunar-archive-plugin file-roller \
    gvfs gvfs-mtp gvfs-smb gvfs-fuse \
    mousepad ristretto \
    pipewire pipewire-pulseaudio wireplumber pavucontrol \
    bluez blueman \
    firefox flatpak \
    glibc-langpack-pt glibc-langpack-en

# ---------- 4. Notebook, energia e baixo consumo de RAM ----------
# TLP gerencia a bateria; não pode rodar junto com o power-profiles-daemon
dnf5 -y remove power-profiles-daemon || true
dnf5 -y install --setopt=install_weak_deps=False --skip-unavailable \
    tlp tlp-rdw thermald earlyoom zram-generator-defaults fwupd irqbalance

# ---------- 5. Impressoras (opcional) ----------
if [ "$ENABLE_PRINTING" = true ]; then
    dnf5 -y install --setopt=install_weak_deps=False --skip-unavailable \
        cups cups-filters system-config-printer
    systemctl enable cups.socket
fi

# ---------- 6. Serviços ----------
systemctl set-default graphical.target
systemctl enable --force lightdm.service
systemctl enable NetworkManager.service

for u in bluetooth.service tlp.service thermald.service earlyoom.service \
         irqbalance.service fstrim.timer fwupd-refresh.timer; do
    systemctl enable "$u" || echo "AVISO: não foi possível habilitar $u"
done

# Desabilita o que atrasa o boot e consome RAM na maioria dos PCs
# (earlyoom substitui o systemd-oomd; ModemManager só é útil com modem 3G/4G)
for u in ModemManager.service NetworkManager-wait-online.service systemd-oomd.service; do
    systemctl disable "$u" || true
done

# Necessário para o TLP controlar rádios (Wi-Fi/Bluetooth)
systemctl mask systemd-rfkill.service systemd-rfkill.socket || true

# ---------- 7. Limpeza ----------
dnf5 clean all
