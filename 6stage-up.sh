#!/bin/bash

ARG=$1

if [ -z "$ARG" ] ; then
  echo USAGE: $0 source-stage
  echo stages are :
  echo dev : to stage from dev to stage1
  echo stage1 : to stage from stage1 to stage2
  echo stage2 : to stage from stage2 to stable
  echo stable : to stage from stabe to rock-solid
  exit
fi

if [ "$ARG" == "dev" ] ; then
  cp -r /var/www/firmware2/dev/* /var/www/firmware2/stage1/
fi

if [ "$ARG" == "stage1" ] ; then
  cp -r /var/www/firmware2/stage1/* /var/www/firmware2/stage2/
fi

if [ "$ARG" == "stage2" ] ; then
  cp -r /var/www/firmware2/stage2/* /var/www/firmware2/stable/
fi

if [ "$ARG" == "stable" ] ; then
  cp -r /var/www/firmware2/stable/* /var/www/firmware2/rocksolid/
fi
