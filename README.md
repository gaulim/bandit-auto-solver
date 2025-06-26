# 🕵️ Bandit Auto Solver

<!-- ![stars](https://img.shields.io/github/stars/gaulim/bandit-auto-solver?style=social) -->
<!-- ![license](https://img.shields.io/github/license/gaulim/bandit-auto-solver) -->

![script](https://img.shields.io/badge/script-zsh-blue)
![lang](https://img.shields.io/github/languages/top/gaulim/bandit-auto-solver)
![code size](https://img.shields.io/github/languages/code-size/gaulim/bandit-auto-solver)
![last commit](https://img.shields.io/github/last-commit/gaulim/bandit-auto-solver)
![auto-run](https://img.shields.io/badge/auto--run-supported-success)

![caffeine](https://img.shields.io/badge/caffeine-900mg-red)
![IQ](https://img.shields.io/badge/IQ-Over_9000%21-yellow)
![hack](https://img.shields.io/badge/hack_mode-enabled-brightgreen)
![nerd](https://img.shields.io/badge/status-certified--nerd-blueviolet)

Automated solver for [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) wargame (Levels 0 to 33)

## ✨ Features

- 🔐 Automatically inputs saved passwords via `sshpass`
- 📜 Stores logs to `/tmp/bandit-auto-solver/logs/YYYY-MM-DD.log`
- ✅ Saves passwords to `~/.bandit_pass/bandit##`
- 🛠 Supports CLI options (`--level`, `--connect-only`, `--no-interactive`, `--quiet`, `--test`, `--dry-run`)
- ⚙️ Makefile with commands to connect, run, auto, test, clean

## 📦 Project Structure

```text
bandit-auto-solver/
├── plugins/             # Helper plugin scripts
├── bandit-auto.zsh      # Sequential runner from level 0 to 33
├── bandit-levels.json   # JSON configuration with per-level commands, descriptions, and hints
├── bandit.zsh           # Single-level executor with password auto-login
├── LICENSE              # MIT License file
├── Makefile             # run/auto/test/clean commands
├── README.md            # This file
```

## 🚀 Usage

```zsh
# Connect only one level
make connect
make connect level={number}

# Run one level interactively
make run
make run level={number}

# Run all levels from 0 to 33
make auto

# Test
make test

# Clean stored passwords and logs
make clean
```

## 🛡️ Notes

- Make sure you have `jq` installed
  - macOS: `brew install jq`
  - Redhat: `sudo yum install jq`
  - Ubuntu: `sudo apt install jq`

- Make sure you have `sshpass` installed
  - macOS: `brew install sshpass`
  - Redhat: `sudo yum install sshpass`
  - Ubuntu: `sudo apt install sshpass`

## 🔐 Security Warning

This tool is for educational use only. Do not use `sshpass` with sensitive systems.  
Passwords are stored in plaintext in `~/.bandit_pass/`.

## 📄 License

This project is licensed under the [MIT License](./LICENSE) by **gaulim**.
