#!/bin/bash
GOOS=darwin GOARCH=amd64 go build -ldflags="-w -s" -ldflags="mmacosx-version-min=10.9" -o macos-web-app-10.9.app/Contents/MacOS/Restar.amd64
GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 go build -ldflags="-w -s" -ldflags="mmacosx-version-min=10.9" -o macos-web-app-10.9.app/Contents/MacOS/Restar.arm64
lipo -create -output "macos-web-app-10.9.app/Contents/MacOS/Restar" "macos-web-app-10.9.app/Contents/MacOS/Restar.amd64" "macos-web-app-10.9.app/Contents/MacOS/Restar.arm64"
