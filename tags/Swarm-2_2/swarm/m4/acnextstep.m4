AC_DEFUN([md_CHECK_NEXTSTEP],
[AC_TRY_CPP([#ifdef NeXT
#error
#endif
], NON_NeXT_EXTRA_OBJS='HashTable.lo List.lo', NON_NeXT_EXTRA_OBJS='')
AC_SUBST(NON_NeXT_EXTRA_OBJS)])
