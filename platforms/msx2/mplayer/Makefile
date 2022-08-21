BUILDDIR := ../build/mplayer
LIB := $(BUILDDIR)/mplayer.lib
all: $(LIB)

AS := sdasz80
AR := sdar

SOURCES := $(wildcard *.asm)
OBJS := $(patsubst %.asm,$(BUILDDIR)/%.rel,$(SOURCES))

$(LIB): $(OBJS) $(BUILDDIR)
	$(AR) -rcD $(LIB) $(OBJS)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.rel: %.asm $(BUILDDIR)
	$(AS) -o $@ $<

.PHONY: clean
clean:
	rm -f $(BUILDDIR)

