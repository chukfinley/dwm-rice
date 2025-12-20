# slock - simple screen locker
# See LICENSE file for copyright and license details.

include config.mk

SRC = slock.c
OBJ = ${SRC:.c=.o}

all: slock

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk

slock: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	rm -f slock ${OBJ}

install: slock
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f slock ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/slock
	chmod u+s ${DESTDIR}${PREFIX}/bin/slock

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/slock

.PHONY: all clean install uninstall
