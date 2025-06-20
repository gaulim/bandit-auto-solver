.PHONY: run auto clean

run:
	@printf "\n🚀 Running single Bandit level script (bandit.zsh)...\n"
	@zsh bandit.zsh

auto:
	@printf "\n🤖 Running Bandit automation script (bandit-auto.zsh)...\n"
	@zsh bandit-auto.zsh

clean:
	@printf "\n🧹 Cleaning up directory...\n"
	@rm -rf ~/.bandit_pass
	@rm -rf /tmp/bandit-auto-solver
