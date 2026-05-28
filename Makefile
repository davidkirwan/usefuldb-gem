.PHONY: default help build install release clean

default: help

help:
	@echo "UsefulDB build targets:"
	@echo "  make build    Build the gem into pkg/"
	@echo "  make install  Build and install the gem locally"
	@echo "  make release  Tag, build, and push to RubyGems (maintainers only)"
	@echo "  make clean    Remove built artifacts from pkg/"

build:
	bundle exec rake build

install:
	bundle exec rake install

release:
	bundle exec rake release

clean:
	bundle exec rake clean
