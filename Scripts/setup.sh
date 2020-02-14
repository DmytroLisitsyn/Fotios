#!/bin/bash

echo "ℹ️  Cleaning"

rm -rf ./Carthage

echo ""
echo "ℹ️  Fetching Carthage dependencies"

sh ./scripts/carthage_update.sh

echo ""
echo "✅ All set. Have a nice day!"

