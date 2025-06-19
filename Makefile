.PHONY: run clean

run:
	@printf "\n🚀 Running single Bandit level script (bandit.zsh)...\n"
	@zsh bandit.zsh

clean:
	@printf "\n🧹 Cleaning up directory...\n"
	@rm -rf ~/.bandit_pass
	@rm -rf /tmp/bandit-auto-solver
