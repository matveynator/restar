#!/bin/bash
version="0.0-004"
git_root_path=`git rev-parse --show-toplevel`
execution_file="restar"

go mod download
go mod tidy

echo "Performing tests on all modules..."
go test ./...
if [ $? != "0" ] 
then
  echo "Tests on all modules failed."
  echo "Press any key to continue compilation or CTRL+C to abort."
  read
else 
  echo "Tests on all modules passed."
fi

cd ${git_root_path}/scripts;

mkdir -p ${git_root_path}/binaries/${version};

rm -f ${git_root_path}/binaries/latest; 

cd ${git_root_path}/binaries; ln -s ${version} latest; cd ${git_root_path}/scripts;

#creating universal mac os x app structure:
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app/Contents
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app/Contents/MacOS
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app/Contents/Resources
cp -p ${git_root_path}/icons/Restar.icns ${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app/Contents/Resources/

cat > ${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>CFBundleExecutable</key>
		<string>Restar</string>
		<key>LSMinimumSystemVersion</key>
		<string>10.2</string>
		<key>NSCameraUsageDescription</key>
		<string>Необходимо для получения изображений QR-кодов.</string>
		<key>CFBundleIconFile</key>
		<string>Restar.icns</string>
	</dict>
</plist>
EOF

#creating amd64 mac os x app structure:
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents/MacOS
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents/Resources
cp -p ${git_root_path}/icons/Restar.icns ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents/Resources/

cat > ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>CFBundleExecutable</key>
                <string>Restar</string>
                <key>LSMinimumSystemVersion</key>
                <string>10.2</string>
                <key>NSCameraUsageDescription</key>
                <string>Необходимо для получения изображений QR-кодов.</string>
                <key>CFBundleIconFile</key>
                <string>Restar.icns</string>
        </dict>
</plist>
EOF

#creating arm64 mac os x app structure:
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents/MacOS
mkdir -p ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents/Resources
cp -p ${git_root_path}/icons/Restar.icns ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents/Resources/

cat > ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>CFBundleExecutable</key>
                <string>Restar</string>
                <key>LSMinimumSystemVersion</key>
                <string>10.2</string>
                <key>NSCameraUsageDescription</key>
                <string>Необходимо для получения изображений QR-кодов.</string>
                <key>CFBundleIconFile</key>
                <string>Restar.icns</string>
        </dict>
</plist>
EOF




#compile gui app:
GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build -ldflags "-w -s -linkmode=external -extldflags '-mmacosx-version-min=10.9' -X restar/pkg/config.CompileVersion=${version}" -o ${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents/MacOS/Restar ../restar.go 2> /dev/null

GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 go build -ldflags "-w -s -linkmode=external -extldflags '-mmacosx-version-min=10.9' -X restar/pkg/config.CompileVersion=${version}" -o ${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents/MacOS/Restar ../restar.go 2> /dev/null

lipo -create -output "${git_root_path}/binaries/${version}/restar-${version}-universal-mac.app/Contents/MacOS/Restar" "${git_root_path}/binaries/${version}/restar-${version}-amd64-mac.app/Contents/MacOS/Restar" "${git_root_path}/binaries/${version}/restar-${version}-arm64-mac.app/Contents/MacOS/Restar"

cd ${git_root_path}/binaries/${version}
zip -r restar-${version}-universal-mac.app.zip restar-${version}-universal-mac.app
zip -r restar-${version}-amd64-mac.app.zip restar-${version}-amd64-mac.app
zip -r restar-${version}-arm64-mac.app.zip restar-${version}-arm64-mac.app

rm -rf restar-${version}-universal-mac.app/ restar-${version}-arm64-mac.app/ restar-${version}-amd64-mac.app;

cd ${git_root_path}

#optional: publish to internet:
rsync -avP binaries/* files@files.matveynator.ru:/home/files/public_html/restar/

