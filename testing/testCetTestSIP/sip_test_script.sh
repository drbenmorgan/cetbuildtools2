#!/usr/bin/env bash

__SYSTEM_LIBRARY_PATH_NAME="LD_LIBRARY_PATH"
if [[ $(uname) == 'Darwin' ]]; then
  __SYSTEM_LIBRARY_PATH_NAME="DYLD_LIBRARY_PATH"
fi

if [ "x${!__SYSTEM_LIBRARY_PATH_NAME}x" == "xx" ]; then
  exit 1
else
  echo "x${!__SYSTEM_LIBRARY_PATH_NAME}x"
fi
