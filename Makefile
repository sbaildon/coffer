ROOTFS ?= rootfs

.PHONY: rootfs install clean

UNITS = $(patsubst dist/%,$(ROOTFS)/%,$(wildcard dist/usr/lib/systemd/system/*))

MOUNTPOINTS = proc sys dev run tmp var/tmp var/lib/coffer

rootfs: $(ROOTFS)/etc/os-release $(ROOTFS)/etc/machine-id $(ROOTFS)/etc/resolv.conf $(ROOTFS)/usr/local/bin/coffer.py $(UNITS)
	install --directory --mode=755 $(addprefix $(ROOTFS)/,$(MOUNTPOINTS))

image: rootfs
	mkfs.erofs -zzstd --all-root ./coffer.raw $(ROOTFS)/

$(ROOTFS)/etc/os-release:
	install --directory --mode=755 $(ROOTFS)/etc
	printf 'ID=coffer\nVERSION_ID=0.1.0\nPORTABLE_PREFIXES=coffer\n' > $@

$(ROOTFS)/etc/machine-id $(ROOTFS)/etc/resolv.conf:
	install --directory --mode=755 $(ROOTFS)/etc
	touch $@

$(ROOTFS)/usr/local/bin/coffer.py: coffer.py
	install --directory --mode=755 $(ROOTFS)/usr/local/bin
	install --mode=755 coffer.py $(ROOTFS)/usr/local/bin/coffer.py

$(ROOTFS)/usr/lib/systemd/system/%: dist/usr/lib/systemd/system/%
	install --directory --mode=755 $(ROOTFS)/usr/lib/systemd/system
	install --mode=644 $< $@

install: install-tree

install-tree: rootfs
	cp --recursive $(ROOTFS) /var/lib/portables/coffer

install-raw: 
	mkfs.erofs -zzstd --all-root /var/lib/portables/coffer.raw $(ROOTFS)/

clean:
	rm -rf $(ROOTFS)
