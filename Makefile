# Rules used to check, test and build Python wheels

BUILDER_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR:=$(realpath $(BUILDER_DIR)../)
PROJECT_DOC_DIR:=$(PROJECT_DIR)/docs
PROJECT_TEST_DIR:=$(PROJECT_DIR)/tests
PROJECT_BUILD_SCRIPT:=$(PROJECT_DIR)/build.sh
PROJECT_VERSION:=$(shell cd $(PROJECT_DIR) && python setup.py --version)

$(PROJECT_BUILD_SCRIPT):
	# build.sh may contain local build rules specific to a project, i.e.
	# rules to generate some GRPC files etc...
	echo "$(PROJECT_BUILD_SCRIPT) DOES NOT EXIST, MAKE EMPTY FILE..."
	touch $(PROJECT_DIR)/build.sh
	chmod +x $(PROJECT_DIR)/build.sh

$(PROJECT_TEST_DIR):
	echo "$(PROJECT_TEST_DIR) DOES NOT EXIST! MAKING EMPTY DIRECTORY (WRITE SOME TESTS)..."
	mkdir $(PROJECT_DIR)/tests

.PHONY: docs-clean
docs-clean:
	echo "CLEANING DOCS..."
	rm -rf $(PROJECT_DOC_DIR)/build

.PHONY: clean
clean: docs-clean
	echo "CLEANING ARTIFACTS..."
	cd $(PROJECT_DIR) && git clean -dfx

.PHONY: install-requirements
install-requirements:
	echo "INSTALLING REQUIREMENTS..."
	pip install -r $(PROJECT_DIR)/requirements-dev.txt

.PHONY: install
install: install-requirements | $(PROJECT_BUILD_SCRIPT)
	echo "INSTALLING PYTHON MODULE..."
	# Run the build.sh script from the project root as it may use relative paths
	cd $(PROJECT_DIR) && /bin/bash build.sh
	cd $(PROJECT_DIR) && pip install -e $(PROJECT_DIR) --no-deps

.PHONY: test 
test: install | $(PROJECT_TEST_DIR)
	echo "RUNNING PYTEST..."
	/bin/bash -c 'pytest -sv --log-cli-level=INFO --junitxml $(PROJECT_DIR)/testresults.xml $(PROJECT_DIR)/tests; ret=$$?; [ $$ret = 5 ] && exit 0 || exit $$ret'

.PHONY: wheel
wheel: test 
	echo "BUILDING WHEEL..."
	cd $(PROJECT_DIR) && python $(PROJECT_DIR)/setup.py bdist_wheel

.PHONY: docs
docs: install docs-clean
	cd $(PROJECT_DOC_DIR) && sphinx-build -b html source/ build

.PHONY: check
check: install 
	# PROJECT_NAME is an environment variable which is set by env.sh
	cd $(PROJECT_DIR) && pylint -f parseable --rcfile=$(BUILDER_DIR)pylintrc ${PROJECT_NAME} --exit-zero | tee pylint.out

.PHONY: check-strict
check-strict:
	# PROJECT_NAME is an environment variable which is set by env.sh
	cd $(PROJECT_DIR) && pylint -f parseable --rcfile=$(BUILDER_DIR)pylintrc ${PROJECT_NAME} | tee pylint.out

.PHONY: docs-clean
docs-clean:
	rm -rf $(PROJECT_DOC_DIR)/build

.PHONY: docs
docs: install docs-clean
	cd $(PROJECT_DOC_DIR) && sphinx-build -b html source/ build

.PHONY: publish-docs
publish-docs: docs
	echo "PUBLISING HTML DOCS..."
	# cd $(PROJECT_DOC_DIR)/build && cp * <remote_dir>
