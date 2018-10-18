#!/usr/bin/env bash

set -eu

rm -rf internal/*
find . -type l -not -path './.git/*' -exec rm {} \;
curl -sfSL https://github.com/gcc-mirror/gcc/archive/gcc-8_2_0-release.tar.gz | \
  tar xzf - -C internal --wildcards --strip-components=1 '*-release/'{libbacktrace/'*'.{c,h},include/{{ansidecl,filenames,hashtab}.h,dwarf2.{def,h}}}

patch -p1 < build.patch

# symlink so cgo compiles them
find internal -name '*.c' \
  -not -name btest.c \
  -not -name edtest.c \
  -not -name edtest2.c \
  -not -name mmap.c \
  -not -name mmapio.c \
  -not -name nounwind.c \
  -not -name stest.c \
  -not -name testlib.c \
  -not -name testlib.h \
  -not -name ttest.c \
  -not -name xcoff.c \
  -not -name ztest.c \
  -exec ln -vsf {} . \;

# temporary hack so this can be used via gazelle
# (gazelle and/or rules_go doesn't know to include headers as specified via #cgo CFLAGS: -I<path>)
# https://github.com/bazelbuild/bazel-gazelle/issues/348
find internal \( -name '*.h' -o -name '*.def' \) \
  -exec ln -vsf {} . \;

# additional hack for gazelle
sed -i 's|"dwarf2\.def"|"dwarf2.def.h"|' dwarf2.h
mv -v dwarf2.def{,.h}

git clean -dXf
