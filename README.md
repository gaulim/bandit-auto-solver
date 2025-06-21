# 🕵️ Bandit Auto Solver

Automated solver for [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) wargame (Levels 0 to 33)

## ✨ Features

- 🔐 Automatically inputs saved passwords via `sshpass`
- 📜 Stores logs to `/tmp/bandit-auto-solver/logs/YYYY-MM-DD.log`
- ✅ Saves passwords to `~/.bandit_pass/bandit##`
- 🛠 Supports CLI options (`--level`, `--no-interactive`, `--quiet`, `--test`, `--dry-run`)
- ⚙️ Makefile with commands to run, auto, test, clean

## 📦 Project Structure

```text
bandit-auto-solver/
├── bandit-auto.zsh      # Sequential runner from level 0 to 33
├── bandit.zsh           # Single-level executor with password auto-login
├── LICENSE              # MIT License file
├── Makefile             # run/auto/test/clean commands
├── README.md            # This file
```

## 🚀 Usage

```zsh
# Run one level interactively
make run

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
