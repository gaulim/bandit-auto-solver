.PHONY: run auto test clean

run:
	@printf "\n🚀 Running single Bandit level script (bandit.zsh)...\n"
	@zsh bandit.zsh

auto:
	@printf "\n🤖 Running Bandit automation script (bandit-auto.zsh)...\n"
	@zsh bandit-auto.zsh

test:
	@printf "\n🧪 Testing Bandit (bandit.zsh)...\n"
	@zsh bandit.zsh --test

clean:
	@printf "\n🧹 Cleaning up directory...\n"
	@rm -rf ~/.bandit_pass
	@rm -rf /tmp/bandit-auto-solver
