PREFIX?=/usr
DOCDIR_PREFIX=$(PREFIX)/share/doc
DOCDIR=$(DOCDIR_PREFIX)/$(self)
ZSHDIR=$(PREFIX)/share/zsh/vendor-completions
RONN ?= ronn

self=vcsh
manpages=$(self).1
all=test manpages

all: $(all)

install: all
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 $(self) $(DESTDIR)$(PREFIX)/bin
	install -m 0644 $(self)-functions $(DESTDIR)$(PREFIX)/bin
	install -d $(DESTDIR)$(PREFIX)/share/man/man1
	install -m 0644 $(manpages) $(DESTDIR)$(PREFIX)/share/man/man1
	install -d $(DESTDIR)$(DOCDIR)
	install -m 0644 README.md $(DESTDIR)$(DOCDIR)
	install -m 0644 doc/hooks $(DESTDIR)$(DOCDIR)
	install -d $(DESTDIR)$(ZSHDIR)
	install -m 0644 _$(self) $(DESTDIR)$(ZSHDIR)

manpages: $(manpages)

$(self).1: doc/$(self).1.ronn
	$(RONN) < doc/$(self).1.ronn > $(self).1 || rm $(self).1

clean:
	rm -rf $(self).1

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/bin/$(self)
	rm -rf $(DESTDIR)$(PREFIX)/bin/$(self)-functions
	rm -rf $(DESTDIR)$(PREFIX)/share/man/man1/$(self).1
	rm -rf $(DESTDIR)$(DOCDIR)
	rm -rf $(DESTDIR)$(ZSHDIR)/_$(self)

# Potentially harmful, used a non-standard option on purpose.
# If PREFIX=/usr/local and that's empty...
purge: uninstall
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(PREFIX)/bin/
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(PREFIX)/share/man/man1/
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(DOCDIR)
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(ZSHDIR)

vcsh_testrepo.git:
	git clone --mirror https://github.com/djpohly/vcsh_testrepo.git

test: | vcsh_testrepo.git
	@if ! which git  > /dev/null; then echo "'git' not found, exiting..."        ; exit 1; fi
	@if ! which bats > /dev/null; then echo "'bats' not found; not running tests"; exit 1; fi
	TESTREPO=$(PWD)/vcsh_testrepo.git TESTREPONAME=vcsh_testrepo prove $(filter -j%,$(MAKEFLAGS)) --timer -e bats bats/*.bats

test-%: bats/%.bats | vcsh_testrepo.git
	TESTREPO=$(PWD)/vcsh_testrepo.git TESTREPONAME=vcsh_testrepo bats $<

moo:
	@which cowsay >/dev/null 2>&1 && cowsay "I hope you're happy now..."
