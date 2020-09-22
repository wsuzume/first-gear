#!/bin/bash

if [ "${OS}" == "Linux" -o "${OS}" == "Darwin" ]; then
  echo "OS: ${OS}"
  echo "---"
  echo "overwrite APPNAME=${APPNAME}"
  echo "---"
  flist=`find ./ -name 'Makefile' | grep -v './/Makefile'`
  for file in ${flist}
  do
    echo "${file} --> ${file}.bk"
    cp "${file}" "${file}.bk"
    sed -e "1s/^APPNAME=.*/APPNAME=${APPNAME}/" ${file}.bk > ${file}
  done
else
  echo "Unrecognized OS: failure"
fi
