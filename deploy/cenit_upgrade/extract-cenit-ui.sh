#!/bin/bash

set -x
set -e

ls -al
pwd
cd cenit-ui
pwd
tar -xvzf cenit-ui.tar.gz

ls -al

rm -rf .git
rm -rf cenit-ui.tar.gz

ls -al