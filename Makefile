
.PHONY: link
link:
	./scripts/link.sh

.PHONY: setup-mac
setup-mac:
	./scripts/setup-mac.sh

.PHONY: setup-python
setup-python:
	./scripts/setup-python.sh

.PHONY: setup-fish
setup-fish:
	./scripts/setup-fish.sh

.PHONY: install
install:
	./scripts/install.sh
