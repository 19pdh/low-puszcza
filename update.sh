#!/bin/sh

nix-prefetch-git "https://github.com/19pdh/kronika" | jq '{ rev: .rev, sha256: .sha256 }' > kronika.json
