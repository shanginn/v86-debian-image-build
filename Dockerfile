FROM i386/debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -q update && \
    apt-get -y install \
        linux-image-686 net-tools grub2 systemd wget curl iproute2 dhcpcd5

COPY config/getty-noclear.conf config/getty-override.conf /etc/systemd/system/getty@tty1.service.d/
COPY config/getty-autologin-serial.conf /etc/systemd/system/serial-getty@ttyS0.service.d/
COPY config/logind.conf /etc/systemd/logind.conf
COPY config/xorg.conf /etc/X11/
COPY config/networking.sh /root/
COPY config/boot-9p /etc/initramfs-tools/scripts/boot-9p

RUN printf '%s\n' 9p 9pnet 9pnet_virtio virtio virtio_ring virtio_pci | tee -a /etc/initramfs-tools/modules && \
    echo 'BOOT=boot-9p' | tee -a /etc/initramfs-tools/initramfs.conf && \
    update-initramfs -u