AC_DEFUN(md_FIND_GNUSTEPLIB,
[
GNUSTEPLIBINCLUDES='-DGNUSTEP -I${GNUSTEP_SYSTEM_ROOT}/Headers -I${GNUSTEP_SYSTEM_ROOT}/Headers/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS} -I${GNUSTEP_SYSTEM_ROOT}/Headers/gnustep'
GNUSTEPLIBLDFLAGS='-L${GNUSTEP_SYSTEM_ROOT}/Libraries/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/gnu-gnu-gnu'
GNUSTEPLIBLIBS=-lgnustep-base
GNUSTEPLIBDEBUGLIBS=-lgnustep-base_d
GNUSTEPLIB=yes
DISABLE_OBJC=yes
LIBOBJCINCLUDES=''
GNUSTEPMODULE='swarmgstep'
AC_SUBST(GNUSTEPLIBINCLUDES)
AC_SUBST(GNUSTEPLIBLDFLAGS)
AC_SUBST(GNUSTEPLIBLIBS)
AC_SUBST(GNUSTEPLIBDEBUGLIBS)
AC_SUBST(GNUSTEPLIB)
AC_SUBST(DISABLE_OBJC)
AC_SUBST(LIBOBJCINCLUDES)
AC_SUBST(GNUSTEPMODULE)
])

