# Makefile for NeoZip, NeoZipNote, NeoZipCloak and NeoZipSplit


#MAKE = make -f unix/Makefile
MAKEF = -f Makefile

# (to use the GNU compiler, change cc to gcc in CC)
CC = cc
BIND = $(CC)
AS = $(CC) -c
CPP = /lib/cpp
E =

# probably can change this to 'install' if you have it
INSTALL_PROGRAM = cp
# probably can change this to 'install -d' if you have it
# XXX NextStep 3.3 and Openstep 4.x don't know about -p !

#edit 1/15/19 (move all object files into "object" directory)
OBJECT_D = mkdir object
MOVE_OBJECT_FILES = mv flags* neozip.o neozipfile.o zipup.o fileio.o util.o crc32.o crypt.o\
					deflate.o globals.o ttyio.o unix.o zbz2err.o trees.o neozipcloak.o fileio_.o\
					neozipfile_.o crc32_.o crypt_.o unix_.o util_.o neozipnote.o neozipsplit.o object/


# flags
#   CFLAGS    flags for C compile
#   LFLAGS1   flags after output file spec, before obj file list
#   LFLAGS2   flags after obj file list (libraries, etc)
CFLAGS_NOOPT = -I. -DUNIX $(LOCAL_ZIP)
CFLAGS = -O2 $(CFLAGS_NOOPT)
LFLAGS1 =
LFLAGS2 = -s

# object file lists
OBJZ = neozip.o neozipfile.o zipup.o fileio.o util.o globals.o crypt.o ttyio.o \
       unix.o crc32.o zbz2err.o
OBJI = deflate.o trees.o
OBJA =
OCRCU8 =
OCRCTB = crc32_.o
OBJU = neozipfile_.o fileio_.o util_.o globals.o unix_.o $(OCRCU8)
OBJN = neozipnote.o  $(OBJU)
OBJC = neozipcloak.o $(OBJU) $(OCRCTB) crypt_.o ttyio.o
OBJS = neozipsplit.o $(OBJU)

ZIP_H = neozip.h ziperr.h tailor.h unix/osdep.h

# suffix rules
.SUFFIXES:
.SUFFIXES: _.o .o .c .doc .1
.c_.o:
	$(CC) -c $(CFLAGS) -DUTIL -o $@ $<

.c.o:
	$(CC) -c $(CFLAGS) $<

# rules for neozip, neozipnote, neozipcloak, neozipsplit
$(OBJZ): $(ZIP_H)
$(OBJI): $(ZIP_H)
$(OBJN): $(ZIP_H)
$(OBJS): $(ZIP_H)
$(OBJC): $(ZIP_H)
neozip.o zipup.o neozipfile.o fileio.o crc32.o crypt.o: crc32.h
neozipcloak.o neozipfile_.o fileio_.o crc32_.o crypt_.o: crc32.h
neozip.o zipup.o crypt.o ttyio.o neozipcloak.o crypt_.o: crypt.h
neozip.o zipup.o neozipnote.o neozipcloak.o neozipsplit.o: revision.h
neozip.o crypt.o ttyio.o neozipcloak.o crypt_.o: ttyio.h
zipup.o: unix/zipup.h

match.o: match.S
	$(CPP) match.S > _match.s
	$(AS) _match.s
	mv _match.o match.o
	rm -f _match.s

unix.o: unix/unix.c
	$(CC) -c $(CFLAGS) unix/unix.c

unix_.o: unix/unix.c
	$(CC) -c $(CFLAGS) -DUTIL -o $@ unix/unix.c

ZIPS = neozip$E neozipcloak$E neozipnote$E neozipsplit$E

zips: $(ZIPS)

neozip$E: $(OBJZ) $(OBJI) $(OBJA) $(LIB_BZ)
	$(BIND) -o neozip$E $(LFLAGS1) $(OBJZ) $(OBJI) $(OBJA) $(LFLAGS2)

neozipnote$E: $(OBJN)
	$(BIND) -o neozipnote$E $(LFLAGS1) $(OBJN) $(LFLAGS2)
neozipcloak$E: $(OBJC) $(OCRCTB)
	$(BIND) -o neozipcloak$E $(LFLAGS1) $(OBJC) $(LFLAGS2)
neozipsplit$E: $(OBJS)
	$(BIND) -o neozipsplit$E $(LFLAGS1) $(OBJS) $(LFLAGS2)

#removes all neozip related .exe files 1/16/19 Lee
uninstall:
	rm neozip neozipcloak neozipnote neozipsplit


flags:  unix/configure
	sh unix/configure "${CC}" "${CFLAGS_NOOPT}" "${IZ_BZIP2}"


#               Generic targets:
#added to generic command: creat object dir, move object files to object dir 1/15/19 Lee
generic: flags
	eval $(MAKE) $(MAKEF) zips `cat flags`
	$(OBJECT_D)
	$(MOVE_OBJECT_FILES)



# clean up after making stuff and installing it
#remove object folder 1/16/19 Lee
clean:
	rm -f *.o $(ZIPS) flags
	rm -rf $(PKGDIR)
	rm -rf object

