# 🥩 termux-beef

> **BeEF (Browser Exploitation Framework) installer for Termux on Android — no laptop needed.**

[![Made by Edun](https://img.shields.io/badge/Made%20by-Edun%20David-00ff41?style=flat-square&labelColor=0a0a0a)](https://youtube.com/@smarttechprogramming)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Termux-00ff41?style=flat-square&labelColor=0a0a0a)](https://github.com/edunoluwadarasimidavid/BeEF-IN-TERMUX)
[![License](https://img.shields.io/badge/License-Educational%20Use-00ff41?style=flat-square&labelColor=0a0a0a)](./LICENSE)

---

## 📖 What is termux-beef?

**termux-beef** is a fully automated shell script that installs the [BeEF (Browser Exploitation Framework)](https://beefproject.com) on **Android using Termux** — without a laptop or PC.

BeEF is a professional penetration testing tool that focuses on browser-based attack vectors. It allows security researchers to hook web browsers and assess their security posture from within the browser context. This script handles all the Termux-specific compatibility issues that normally make BeEF painful to install on Android.

> ⚠️ **For educational and ethical use only.** Only use BeEF on systems and browsers you own or have explicit written permission to test. Unauthorized use is illegal.

---

## ✨ Features

- ✅ One-command automated install — no manual gem fixing
- ✅ Handles all known Termux compatibility errors automatically
- ✅ Pre-fixes `nokogiri` and `eventmachine` (the #1 cause of BeEF install failures on Android)
- ✅ Installs all required system dependencies via `pkg`
- ✅ Updates RubyGems before installing
- ✅ Sets `bundle config` flags so gems compile correctly every time
- ✅ Termux storage permission check before install begins
- ✅ Cleans up old installs automatically if you re-run the script
- ✅ No root required

---

## 📱 Requirements

| Requirement | Details |
|---|---|
| Device | Android phone or tablet |
| App | [Termux](https://f-droid.org/en/packages/com.termux/) (install from **F-Droid**, NOT Play Store) |
| Storage Permission | Must be granted via `termux-setup-storage` |
| Internet | Stable connection required (install can take 10–30 mins) |
| RAM | 2GB minimum recommended |
| Storage | At least 1GB free space |

> ⚠️ **Important:** Do NOT use the Play Store version of Termux. It is outdated and will cause errors. Download Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/) or [GitHub Releases](https://github.com/termux/termux-app/releases).

---

## ⚡ Quick Install

### Step 1 — Grant storage permission (first time only)
```bash
termux-setup-storage
```
Tap **Allow** when prompted. Then restart Termux.

### Step 2 — Clone this repo
```bash
git clone https://github.com/edunoluwadarasimidavid/BeEF-IN-TERMUX.git
```

### Step 3 — Enter the folder
```bash
cd BeEF-IN-TERMUX
```

### Step 4 — Give the script execute permission
```bash
chmod +x termux-beef.sh
```

### Step 5 — Run the installer
```bash
./termux-beef.sh
```

Follow the on-screen prompts. The script will handle everything automatically.

---

## 🚀 After Install — How to Run BeEF

Once the install is complete:

```bash
# Navigate to the beef folder
cd ~/beef

# Change the default password first (important!)
nano config.yaml
```

Find this section in `config.yaml` and change the password:
```yaml
credentials:
  user:   "beef"
  passwd: "your_new_password_here"
```

Then launch BeEF:
```bash
./beef
```

Open your browser and go to:
```
http://127.0.0.1:3000/ui/panel
```

Login with your credentials. BeEF is now running on your Android phone.

---

## 🔧 What the Script Does (Step by Step)

| Step | Function | What it does |
|---|---|---|
| 1 | `check_termux_storage` | Reminds you to grant storage permission before anything runs |
| 2 | `get_permission` | Confirms you want to proceed with the install |
| 3 | `check_os` | Detects Termux environment — blocks non-Android systems |
| 4 | `install_termux` | Runs `pkg update` + installs all system dependencies |
| 5 | `check_ruby_version` | Verifies Ruby 3.0+ is installed |
| 6 | `update_rubygems` | Updates RubyGems to latest version |
| 7 | `check_bundler` | Installs bundler gem if not already present |
| 8 | `fix_problem_gems` | Pre-installs `nokogiri` and `eventmachine` with Termux-specific flags |
| 9 | `install_beef` | Sets `bundle config` flags and runs `bundle install` for all gems |
| 10 | `finish` | Moves BeEF to `~/beef` and shows next steps |

---

## 🐛 Known Issues & Fixes

### ❌ `eventmachine` — cannot find `libssl.so`
This is the most common BeEF error on Termux. The script fixes it automatically by building eventmachine with:
```bash
--with-openssl-dir=$PREFIX
```

### ❌ `nokogiri` — build fails on aarch64
Fixed by installing with system libraries and the correct include path:
```bash
gem install nokogiri --platform=ruby -- --use-system-libraries
```

### ❌ `FATAL: Unable to locate installer for your Linux distribution`
This happens when using the original BeEF install script on Termux. This script replaces it entirely with a Termux-native installer.

### ❌ Script fails halfway through
Re-run the script. It will automatically delete the old `beef` folder and start fresh.

### ❌ `pkg: command not found`
You are using an outdated Termux from the Play Store. Reinstall from [F-Droid](https://f-droid.org/en/packages/com.termux/).

---

## 📂 Repository Structure

```
BeEF-IN-TERMUX/
├── termux-beef.sh      # Main installer script
├── README.md           # This file
└── LICENSE             # License
```

---

## 🔐 Ethical Use & Legal Disclaimer

This tool is provided **strictly for educational purposes** and authorized penetration testing.

- ✅ Legal: Testing on your own devices and networks
- ✅ Legal: Authorized bug bounty programs
- ✅ Legal: Cybersecurity research in controlled lab environments
- ❌ Illegal: Testing on devices/networks without permission
- ❌ Illegal: Any malicious or unauthorized use

The author takes **no responsibility** for any misuse of this tool. By using this script, you agree to use BeEF only on systems you own or have explicit written authorization to test.

---


| Platform | Link |
|---|---|
| 🎥 YouTube | [@smarttechprogramming](https://youtube.com/@smarttechprogramming?si=gAvPpjmosWXC81Vh) |
| 🐙 GitHub | [edunoluwadarasimidavid](https://github.com/edunoluwadarasimidavid) |

---

## ⭐ Support

If this script helped you, consider:
- ⭐ **Starring this repo** on GitHub
- 🔔 **Subscribing** to the YouTube channel for more Android hacking & dev tutorials

---

## 📜 License

This project is licensed for educational use. BeEF itself is licensed under the terms found in [BeEF's repository](https://github.com/beefproject/beef/blob/master/doc/COPYING).
