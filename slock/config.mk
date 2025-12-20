# slock - simple screen locker
# See LICENSE file for copyright and license details.

VERSION = 1.6

PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# FreeBSD (comment out above and uncomment below)
#X11INC = /usr/local/include
#X11LIB = /usr/local/lib

# includes and libs
INCS = -I. -I/usr/include -I${X11INC}
LIBS = -L/usr/lib -lc -lcrypt -L${X11LIB} -lX11 -lXext -lXrandr

# flags
CPPFLAGS = -DVERSION=\"${VERSION}\" -D_DEFAULT_SOURCE -DHAVE_SHADOW_H
CFLAGS   = -std=c99 -pedantic -Wall -Os ${INCS} ${CPPFLAGS}
LDFLAGS  = -s ${LIBS}

# compiler and linker
CC = cc
