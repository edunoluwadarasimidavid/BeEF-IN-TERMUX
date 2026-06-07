#!/bin/bash
#
# termux-beef - BeEF Installer for Termux (Android)
# Browser Exploitation Framework (BeEF) - https://beefproject.com
#
# Created by Edun Oluwadarasimi David
# YouTube : https://youtube.com/@smarttechprogramming?si=gAvPpjmosWXC81Vh
# GitHub  : https://github.com/edunoluwadarasimidavid/BeEF-IN-TERMUX
#
# See the file 'doc/COPYING' for copying permission
#

set -euo pipefail
NORMIFS=$IFS
SCRIFS=$'\n\t'
IFS=$SCRIFS

info()  { echo -e "\\033[1;36m[INFO]\\033[0m  $*"; }
warn()  { echo -e "\\033[1;33m[WARNING]\\033[0m  $*"; }
fatal() {
	echo -e "\\033[1;31m[FATAL]\\033[0m  $*"
	exit 1
}

RUBYSUFFIX=''

command_exists() {
	command -v "${1}" >/dev/null 2>&1
}

check_termux_storage() {
	echo
	warn "Make sure you have granted Termux storage permission."
	warn "If you haven't, run: termux-setup-storage"
	warn "Then restart Termux and run this script again."
	echo
	read -rp "Have you granted Termux storage permission? (Y/n) "
	if [ "$(echo "${REPLY}" | tr "[:upper:]" "[:lower:]")" = "n" ]; then
		info "Run 'termux-setup-storage' first, then restart this script."
		exit 1
	fi
}

get_permission() {
	warn "This script will install BeEF and its required dependencies."
	echo
	read -rp "Are you sure you wish to continue? (Y/n) "
	if [ "$(echo "${REPLY}" | tr "[:upper:]" "[:lower:]")" = "n" ]; then
		fatal "Installation aborted."
	fi
}

check_os() {
	info "Detecting OS..."

	OS=$(uname)
	readonly OS
	info "Operating System: $OS"

	if [ "${OS}" = "Linux" ]; then
		if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
			info "Termux environment detected. Launching Termux install..."
			install_termux
		else
			fatal "This script is designed for Termux on Android only. Linux desktop is not supported."
		fi
	else
		fatal "Unsupported OS: ${OS}. This script only runs in Termux on Android."
	fi
}

install_termux() {
	info "Updating Termux packages..."
	pkg update -y && pkg upgrade -y

	info "Installing required dependencies..."
	pkg install -y ruby curl git nodejs python3 openssl readline libyaml libsqlite sqlite libxml2 autoconf ncurses automake libtool bison wget clang

	info "Cloning BeEF repository..."
	git clone --depth=1 https://github.com/beefproject/beef
	cd beef
}

check_ruby_version() {
	info "Detecting Ruby environment..."

	MIN_RUBY_VER='3.0'

	if command_exists rvm; then
		RUBY_VERSION=$(rvm current | cut -d'-' -f 2)
		info "Ruby version ${RUBY_VERSION} is installed with RVM"
		if [ "$(ruby -e "puts RUBY_VERSION.to_f >= ${MIN_RUBY_VER}")" = 'false' ]; then
			fatal "Ruby ${RUBY_VERSION} is not supported. Please install Ruby ${MIN_RUBY_VER} or newer."
		fi
	elif command_exists rbenv; then
		RUBY_VERSION=$(rbenv version | cut -d' ' -f 2)
		info "Ruby version ${RUBY_VERSION} is installed with rbenv"
		if [ "$(ruby -e "puts RUBY_VERSION.to_f >= ${MIN_RUBY_VER}")" = 'false' ]; then
			fatal "Ruby ${RUBY_VERSION} is not supported. Please install Ruby ${MIN_RUBY_VER} or newer."
		fi
	elif command_exists ruby${RUBYSUFFIX}; then
		RUBY_VERSION=$(ruby${RUBYSUFFIX} -e "puts RUBY_VERSION")
		info "Ruby version ${RUBY_VERSION} is installed"
		if [ "$(ruby${RUBYSUFFIX} -e "puts RUBY_VERSION.to_f >= ${MIN_RUBY_VER}")" = 'false' ]; then
			fatal "Ruby ${RUBY_VERSION} is not supported. Please install Ruby ${MIN_RUBY_VER} or newer."
		fi
	else
		fatal "Ruby is not installed. Run: pkg install ruby"
	fi
}

check_bundler() {
	info "Detecting bundler gem..."

	if command_exists bundler${RUBYSUFFIX}; then
		info "bundler gem is already installed."
	else
		info "Installing bundler gem..."
		gem${RUBYSUFFIX} install bundler
	fi
}

install_beef() {
	info "Installing required Ruby gems..."

	if [ -w Gemfile.lock ]; then
		rm Gemfile.lock
	fi

	gem install nokogiri -- --with-cflags="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-incompatible-function-pointer-types" --use-system-libraries

	if command_exists bundle${RUBYSUFFIX}; then
		bundle${RUBYSUFFIX} install
	else
		bundle install
	fi
}

finish() {
	echo
	echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
	echo
	info "termux-beef — Created by Edun Oluwadarasimi David"
	info "YouTube : https://youtube.com/@smarttechprogramming"
	info "GitHub  : https://github.com/edunoluwadarasimidavid/BeEF-IN-TERMUX"
	echo
	info "BeEF installed successfully!"
	info "Run './beef' inside the beef folder to launch."
	echo
	echo "Next steps:"
	echo "  * Change the default password in config.yaml"
	echo "  * Open browser and go to: http://127.0.0.1:3000/ui/panel"
	echo "  * Default credentials: beef / beef"
	echo "  * Review the wiki: https://github.com/beefproject/beef/wiki/Configuration"
	echo
	echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
	echo
	cd ..
	mv beef "${HOME}"
	info "BeEF has been moved to: ${HOME}/beef"
}

main() {
	clear

	echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
	echo "              -- [ termux-beef Installer ] --                    "
	echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
	echo
	info "Created by Edun Oluwadarasimi David"
	info "YouTube : https://youtube.com/@smarttechprogramming"
	info "GitHub  : https://github.com/edunoluwadarasimidavid/BeEF-IN-TERMUX"
	echo

	check_termux_storage
	get_permission
	check_os
	check_ruby_version
	check_bundler
	install_beef
	finish
}

main "$@"
