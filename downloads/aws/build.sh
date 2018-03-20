#!/bin/bash

dir=$(basename $PWD)
tar -czv -f $dir.tar.gz --exclude build.sh .