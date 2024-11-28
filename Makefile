# Variables
SRCDIR = src
BUILDDIR = build

SH_BINS = build-fstab
SCRIPTS = 0-auto-detect 1-install 2-mount 3-tslib 99-fstab-fallback

all: build install clean

build:
	@mkdir -p $(BUILDDIR)

	@install -dm 755 $(BUILDDIR)/usr/bin
	@install -dm 755 $(BUILDDIR)/usr/lib
	@install -dm 755 $(BUILDDIR)/scripts

	@for sh_bin in $(SH_BINS); do \
		shfmt -mn -ln=mksh $(SRCDIR)/bin/$$sh_bin > $(BUILDDIR)/usr/bin/$$sh_bin; \
		chmod 755 $(BUILDDIR)/usr/bin/$$sh_bin; \
	done

	@for script in $(SCRIPTS); do \
		shfmt -mn -ln=mksh $(SRCDIR)/scripts/$$script > $(BUILDDIR)/scripts/$$script; \
		chmod 755 $(BUILDDIR)/scripts/$$script; \
	done

	@echo '#!/bin/busybox sh' > $(BUILDDIR)/init
	@shfmt -mn -ln=mksh $(SRCDIR)/init >> $(BUILDDIR)/init
	@chmod 755 $(BUILDDIR)/init

	@cp -r $(SRCDIR)/etc $(BUILDDIR)/
	@env LC_ALL=C.UTF-8 find $(BUILDDIR) -mindepth 1 -execdir touch -hcd '@0' '{}' +

install:
	@mkdir -p \
		$(DESTDIR)/ \
		$(DESTDIR)/android \
		$(DESTDIR)/scripts \
		$(DESTDIR)/mnt \
		$(DESTDIR)/dev \
		$(DESTDIR)/etc \
		$(DESTDIR)/proc \
		$(DESTDIR)/usr/lib64 \
		$(DESTDIR)/sys \
		$(DESTDIR)/tmp \

	@cp -t $(DESTDIR)/ -r \
		$(BUILDDIR)/usr \
		$(BUILDDIR)/scripts \
		$(BUILDDIR)/etc \
		$(BUILDDIR)/init

	@for dir in bin lib lib64; do \
		if [ ! -h $(DESTDIR)/$$dir ]; then \
			ln -s usr/$$dir $(DESTDIR)/$$dir; \
		fi; \
	done

clean:
	@rm -rf $(BUILDDIR)

.PHONY: all install clean
