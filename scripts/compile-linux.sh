#!/bin/bash
version="0.0-002"
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

GOOS=linux GOARCH=amd64 go build -o ${git_root_path}/binaries/${version}/restar-${version}-amd64-linux.app ../restar.go 
GOOS=linux GOARCH=arm64 CGO_ENABLED=1 go build -o ${git_root_path}/binaries/${version}/restar-${version}-arm64-linux.app ../restar.go 

#optional: publish to internet:
cd ${git_root_path}
rsync -avP binaries/* files@files.matveynator.ru:/home/files/public_html/restar/
