#!/bin/sh

rm MANIFEST
rm META.yml
rm -rf Hook-Filter-*

perl Makefile.PL
make
make manifest
make distdir
make disttest
make tardist
make clean
