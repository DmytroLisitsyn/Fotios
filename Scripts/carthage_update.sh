#!/bin/bash

carthage update --platform iOS --no-use-binaries --no-build

find Carthage -type f -name "*.xcscheme" -print0 | xargs -0 perl -pi -e 's/codeCoverageEnabled = "YES"/codeCoverageEnabled = "NO"/g'

carthage build --platform iOS

