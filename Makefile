.PHONY: link
link:
	./scripts/link.sh

.PHONY: setup-parallel-tasks
setup-parallel-tasks:
	./scripts/setup-parallel-tasks.sh

.PHONY: setup-mac
setup-mac:
	./scripts/setup-mac.sh

.PHONY: setup-python
setup-python:
	./scripts/setup-python.sh

.PHONY: setup-fish
setup-fish:
	./scripts/setup-fish.sh

.PHONY: setup-all
setup-all: setup-parallel-tasks setup-mac install link
	@echo "Complete setup-all finished!"

.PHONY: setup-exclude-parallel-tasks
setup-all: setup-mac install link
	@echo "Complete setup-exclude-parallel-tasks finished!"

.PHONY: install
install:
	./scripts/install.sh
