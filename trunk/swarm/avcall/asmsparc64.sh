#!/bin/sh
# Translate the assembler syntax of sparc64 assembler programs
# Usage: asmsparc < sparclinux-asm-file > portable-asm-file
# The portable-asm-file has to be
#   1. preprocessed,
#   2. grep -v '^ *#line' | grep -v '^#'
#   3. sed -e 's,% ,%,g' -e 's,//.*$,,' -e 's,\$,#,g'
sed -e '# ----------- Remove gcc self-identification' \
    -e '/gcc2_compiled/d' \
    -e '/gnu_compiled_c/d' \
| \
sed -e '# ----------- Turn # into $, to avoid trouble in preprocessing' \
    -e 's,#,\$,g' \
    -e '# ----------- Declare global symbols as functions (we have no variables)' \
    -e 's/\.global \([A-Za-z0-9_]*\)$/.global \1\' \
    -e '	DECLARE_FUNCTION(\1)/'
