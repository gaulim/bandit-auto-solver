.PHONY: connect run auto test clean

# Optional CLI flags
level ?=

connect:
	@printf "\n🔐 Connecting Bandit level script (bandit.zsh)...\n"
	@zsh -c '\
		cmd="./bandit.zsh --connect-only"; \
		if [ -n "$(level)" ]; then cmd="$$cmd --level=$(level)"; fi; \
		echo "🔧 Command: $$cmd"; \
		eval "$$cmd" \
	'

run:
	@printf "\n🚀 Running single Bandit level script (bandit.zsh)...\n"
	@zsh -c '\
		cmd="./bandit.zsh"; \
		if [ -n "$(level)" ]; then cmd="$$cmd --level=$(level)"; fi; \
		echo "🔧 Command: $$cmd"; \
		eval "$$cmd" \
	'

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
