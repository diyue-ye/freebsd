# $Id: MKunctrl.awk,v 1.14 2007/07/28 21:13:21 tom Exp $
##############################################################################
# Copyright (c) 1998-2006,2007 Free Software Foundation, Inc.                #
#                                                                            #
# Permission is hereby granted, free of charge, to any person obtaining a    #
# copy of this software and associated documentation files (the "Software"), #
# to deal in the Software without restriction, including without limitation  #
# the rights to use, copy, modify, merge, publish, distribute, distribute    #
# with modifications, sublicense, and/or sell copies of the Software, and to #
# permit persons to whom the Software is furnished to do so, subject to the  #
# following conditions:                                                      #
#                                                                            #
# The above copyright notice and this permission notice shall be included in #
# all copies or substantial portions of the Software.                        #
#                                                                            #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    #
# THE ABOVE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER        #
# DEALINGS IN THE SOFTWARE.                                                  #
#                                                                            #
# Except as contained in this notice, the name(s) of the above copyright     #
# holders shall not be used in advertising or otherwise to promote the sale, #
# use or other dealings in this Software without prior written               #
# authorization.                                                             #
##############################################################################
#
# Author: Thomas E. Dickey <dickey@clark.net> 1997
#

BEGIN	{
		print "/* generated by MKunctrl.awk */"
		print ""
		print "#include <curses.priv.h>"
		print ""
		print "#undef unctrl"
		print ""
	}
END	{
		print "NCURSES_EXPORT(NCURSES_CONST char *) unctrl (register chtype ch)"
		print "{"

		blob=""
		offset=0
		if (bigstrings) {
			printf "static const short unctrl_table[] = {"
		} else {
			printf "static const char* const unctrl_table[] = {"
		}
		for ( ch = 0; ch < 256; ch++ ) {
			gap = ","
			part=""
			if ((ch % 8) == 0) {
				printf "\n    "
				if (ch != 0)
					blob = blob "\""
				blob = blob "\n    \""
			}
			if (bigstrings)
				printf "%4d%s", offset, gap;
			if (ch < 32) {
				part = sprintf ("^\\%03o", ch + 64);
				offset = offset + 3;
			} else if (ch == 127) {
				part = "^?";
				offset = offset + 3;
			} else if (ch >= 128 && ch < 160) {
				part = sprintf("~\\%03o", ch - 64);
				offset = offset + 3;
			} else {
				gap = gap " "
				part = sprintf("\\%03o", ch);
				offset = offset + 2;
			}
			if (ch == 255)
				gap = "\n"
			else if (((ch + 1) % 8) != 0)
				gap = gap " "
			if (bigstrings) {
				blob = blob part "\\0";
			} else {
				printf "\"%s\"%s", part, gap
			}
		}
		print "};"
		blob = blob "\"";

		print ""
		print "#if NCURSES_EXT_FUNCS"
		if (bigstrings) {
			blob = blob "\n#if NCURSES_EXT_FUNCS"
			printf "static const short unctrl_c1[] = {"
		} else {
			printf "static const char* const unctrl_c1[] = {"
		}
		for ( ch = 128; ch < 160; ch++ ) {
			gap = ","
			if ((ch % 8) == 0) {
				if (ch != 128)
					blob = blob "\""
				printf "\n    "
				blob = blob "\n    \""
			}
			if (bigstrings) {
				printf "%4d%s", offset, gap;
				part = sprintf("\\%03o\\0", ch);
				blob = blob part
				offset = offset + 2;
				if (((ch + 1) % 8) != 0)
					gap = gap " "
			} else {
				if (ch >= 128 && ch < 160) {
					printf "\"\\%03o\"", ch
					gap = gap " "
				}
				if (ch == 255)
					gap = "\n"
				else if (((ch + 1) % 8) != 0)
					gap = gap " "
				printf "%s", gap
			}
		}
		print "};"
		print "#endif /* NCURSES_EXT_FUNCS */"
		blob = blob "\"\n#endif /* NCURSES_EXT_FUNCS */\n"

		print ""
		if (bigstrings) {
			print "static const char unctrl_blob[] = "blob";"
			print ""
			stringname = "unctrl_blob + unctrl"
		} else {
			stringname = "unctrl"
		}
		print "\tint check = ChCharOf(ch);"
		print "\tconst char *result;"
		print ""
		print "\tif (check >= 0 && check < (int)SIZEOF(unctrl_table)) {"
		print "#if NCURSES_EXT_FUNCS"
		print "\t\tif ((SP != 0)"
		print "\t\t && (SP->_legacy_coding > 1)"
		print "\t\t && (check >= 128)"
		print "\t\t && (check < 160))"
		printf "\t\t\tresult = %s_c1[check - 128];\n", stringname;
		print "\t\telse"
		print "#endif /* NCURSES_EXT_FUNCS */"
		printf "\t\t\tresult = %s_table[check];\n", stringname;
		print "\t} else {"
		print "\t\tresult = 0;"
		print "\t}"
		print "\treturn (NCURSES_CONST char *)result;"
		print "}"
	}
