#!/bin/bash
#
# termux-beef - BeEF Installer for Termux (Android)
# Browser Exploitation Framework (BeEF) - https://beefproject.com
#
# Created by Edun Oluwadarasimi David
# YouTube : https://youtube.com/@smarttechprogramming
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

# ──────────────────────────────────────────────
# STEP 1: Termux storage permission reminder
# ──────────────────────────────────────────────
check_termux_storage() {
	echo
	warn "Make sure you have granted Termux storage permission."
	warn "If you haven't, run: termux-setup-storage"
	warn "Then restart Termux and run this script again."
	echo
	read -rp "Have you already granted Termux storage permission? (Y/n) "
	if [ "$(echo "${REPLY}" | tr "[:upper:]" "[:lower:]")" = "n" ]; then
		info "Run 'termux-setup-storage' first, then restart this script."
		exit 1
	fi
}

# ──────────────────────────────────────────────
# STEP 2: User confirmation
# ──────────────────────────────────────────────
get_permission() {
	warn "This script will install BeEF and all required dependencies."
	echo
	read -rp "Are you sure you wish to continue? (Y/n) "
	if [ "$(echo "${REPLY}" | tr "[:upper:]" "[:lower:]")" = "n" ]; then
		fatal "Installation aborted."
	fi
}

# ──────────────────────────────────────────────
# STEP 3: OS check — Termux only
# ──────────────────────────────────────────────
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

# ──────────────────────────────────────────────
# STEP 4: Install all Termux dependencies
# ──────────────────────────────────────────────
install_termux() {
	info "Updating Termux packages..."
	pkg update -y && pkg upgrade -y

	info "Installing required system dependencies..."
	pkg install -y \
		ruby \
		ruby-dev \
		curl \
		git \
		nodejs \
		python3 \
		openssl \
		openssl-dev \
		readline \
		libyaml \
		libyaml-dev \
		libsqlite \
		libxml2 \
		libxml2-dev \
		libxslt \
		libxslt-dev \
		autoconf \
		ncurses \
		automake \
		libtool \
		bison \
		wget \
		clang \
		make \
		pkg-config

	info "Cloning BeEF repository..."
	# Remove old clone if it exists
	if [ -d "beef" ]; then
		warn "Existing 'beef' folder found. Removing it..."
		rm -rf beef
	fi
	git clone --depth=1 https://github.com/beefproject/beef
	cd beef
}

# ──────────────────────────────────────────────
# STEP 5: Check Ruby version
# ──────────────────────────────────────────────
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

# ──────────────────────────────────────────────
# STEP 6: Update RubyGems
# ──────────────────────────────────────────────
update_rubygems() {
	info "Updating RubyGems..."
	gem update --system || warn "RubyGems update failed — continuing anyway."
}

# ──────────────────────────────────────────────
# STEP 7: Install bundler
# ──────────────────────────────────────────────
check_bundler() {
	info "Detecting bundler gem..."

	if command_exists bundler${RUBYSUFFIX}; then
		info "bundler gem is already installed."
	else
		info "Installing bundler gem..."
		gem${RUBYSUFFIX} install bundler
	fi
}

# ──────────────────────────────────────────────
# STEP 8: Pre-install problem gems with Termux fixes
# ──────────────────────────────────────────────
fix_problem_gems() {
	info "Pre-installing known problem gems with Termux-specific fixes..."

	# Fix nokogiri — needs system libraries + gumbo include path
	info "Installing nokogiri (this may take a few minutes)..."
	export C_INCLUDE_PATH="$(find "$PREFIX" -type d -name "gumbo-parser" 2>/dev/null | head -n1)/src"
	gem install nokogiri --platform=ruby -- \
		--use-system-libraries \
		--with-cflags="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-incompatible-function-pointer-types" \
		|| warn "nokogiri pre-install failed — bundle install will retry."

	# Fix eventmachine — needs to link against Termux's OpenSSL correctly
	info "Installing eventmachine with OpenSSL fix..."
	gem install eventmachine -- \
		--with-cflags="-Wno-error=implicit-function-declaration" \
		--with-openssl-dir="$PREFIX" \
		|| warn "eventmachine pre-install failed — bundle install will retry."
}

# ──────────────────────────────────────────────
# STEP 9: Install all BeEF gems via bundler
# ──────────────────────────────────────────────
install_beef() {
	info "Installing all required Ruby gems via bundler..."
	info "Note: This can take 10–30 minutes on mobile. Do NOT close Termux."

	if [ -w Gemfile.lock ]; then
		rm Gemfile.lock
	fi

	# Set build flags for all native gems
	bundle config set --local build.nokogiri \
		"--use-system-libraries --with-cflags='-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-incompatible-function-pointer-types'"
	bundle config set --local build.eventmachine \
		"--with-cflags='-Wno-error=implicit-function-declaration' --with-openssl-dir=$PREFIX"
	bundle config set --local build.thin \
		"--with-cflags='-Wno-error=implicit-function-declaration'"

	if command_exists bundle${RUBYSUFFIX}; then
		bundle${RUBYSUFFIX} install
	else
		bundle install
	fi
}

# ──────────────────────────────────────────────
# STEP 10: Move BeEF to home and finish
# ──────────────────────────────────────────────
finish() {
	echo
	echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
	echo
	info "termux-beef — Created by Edun Oluwadarasimi David"
	info "YouTube : https://youtube.com/@smarttechprogramming"
	info "GitHub  : https://github.com/edunoluwadarasimidavid/BeEF-IN-TERMUX"
	echo
	info "BeEF installed successfully!"
	echo
	echo "Next steps:"
	echo "  1. cd ~/beef"
	echo "  2. Change the default password in config.yaml"
	echo "  3. Run: ./beef"
	echo "  4. Open browser → http://127.0.0.1:3000/ui/panel"
	echo "  5. Default login: beef / beef"
	echo
	echo "  Wiki: https://github.com/beefproject/beef/wiki/Configuration"
	echo
	echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
	echo
	cd ..
	# Only move if not already in home
	if [ "$(pwd)" != "$HOME" ]; then
		mv beef "${HOME}/beef"
		info "BeEF moved to: ${HOME}/beef"
	fi
}

# ──────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────
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
	update_rubygems
	check_bundler
	fix_problem_gems
	install_beef
	finish
}

main "$@"
