#!/bin/sh
# Create a custom keychain
security create-keychain -p travis mac-build.keychain
# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s mac-build.keychain
# Unlock the keychain
security unlock-keychain -p travis mac-build.keychain
# Set keychain timeout to 1 hour for long builds
security set-keychain-settings -t 3600 -l ~/Library/Keychains/mac-build.keychain
# Add certificates to keychain and allow codesign to access them
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/mac-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/mac-build.keychain -T /usr/bin/codesign 
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/mac-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign
# Set Key partition list
security set-key-partition-list -S apple-tool:,apple: -s -k travis mac-build.keychain

