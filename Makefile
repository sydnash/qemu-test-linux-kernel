.PHONY: boot gdb stop unpack_rootfs repack_rootfs

kernel_dir ?= ..

clone:
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git -b master --depth 1

kernel:
	cp config ${kernel_dir}/.config
	cd ${kernel_dir} &&  make

boot:
	qemu-system-aarch64 -M virt -m 1024 -cpu cortex-a57 -kernel /home/sydnash/net-next/arch/arm64/boot/Image -initrd '/boot/initramfs-5.19.0-rc8+.img' -display none -nographic -append "nokaslr rdinit=/bin/bash" -s -S
	#qemu-system-aarch64 -M virt -m 1024 -cpu cortex-a57 -kernel '/boot/vmlinuz-5.19.0-rc8+' -initrd '/boot/initramfs-5.19.0-rc8+.img' -display none -nographic -append "nokaslr rdinit=/bin/bash" -s -S

gdb:
	gdb -ex "target remote localhost:1234" /home/sydnash/net-next/vmlinux

unpack_rootfs:
	mkdir /tmp/initrd
	cd /tmp/initrd && zcat /boot/initrd-$(uname -r).img | cpio -idmv

repack_rootfs:
	cd /tmp/initrd && find . | cpio -o -c -R root:root | gzip -9 > /boot/new.img
