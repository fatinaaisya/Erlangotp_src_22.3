#
# %CopyrightBegin%
#
# Copyright Ericsson AB 1998-2013. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# %CopyrightEnd%

# Toplevel makefile for building the Erlang system
#

.NOTPARALLEL:

# ----------------------------------------------------------------------

# And you'd think that this would be obvious... :-)
SHELL = /bin/sh

# The top directory in which Erlang is unpacked
ERL_TOP = /Users/johnmelody_mynapse/Downloads/otp_src_22.3

# OTP release
OTP = OTP-22

# erts (Erlang RunTime System) version
ERTS = erts-10.7

# Include verbose output variables
include $(ERL_TOP)/make/output.mk

# ----------------------------------------------------------------------

#
# The variables below control where Erlang is installed. They are
# configurable (unless otherwise stated). Some of them are best
# changed by giving special arguments to configure instead of changing
# them in this file. Note: If you change them in Makefile, instead of
# Makefile.in your changes will be lost the next time you run
# configure.
#

# prefix from configure, default is /usr/local (must be an absolute path)
prefix		= /usr/local
exec_prefix	= ${prefix}

# Locations where we should install according to configure. These location
# may be prefixed by $(DESTDIR) and/or $(EXTRA_PREFIX) (see below).
bindir		= ${exec_prefix}/bin
libdir		= ${exec_prefix}/lib

# Where Erlang/OTP is located
libdir_suffix	= /erlang
erlang_libdir	= $(libdir)$(libdir_suffix)
erlang_bindir	= $(erlang_libdir)/bin

#
# By default we install relative symbolic links for $(ERL_BASE_PUB_FILES)
# from $(bindir) to $(erlang_bindir) as long as they are both prefixed
# by $(exec_prefix) (and are otherwise reasonable). This behavior can be
# overridden by passing BINDIR_SYMLINKS=<HOW>, where <HOW> is either
# absolute or relative.
#

# $ make DESTDIR=<...> install
#
# DESTDIR can be set in case you want to install Erlang in a different
# location than where you have configured it to run. This can be
# useful, e.g. when installing on a server that stores the files with a
# different path than where the clients access them, when building
# rpms, or cross compiling, etc. DESTDIR will prefix the actual
# installation which will only be able to run once the DESTDIR prefix
# has disappeard, e.g. the part after DESTDIR has been packed and
# unpacked without DESTDIR. The name DESTDIR have been chosen since it
# is the GNU coding standard way of doing it.
#
# If INSTALL_PREFIX is set but not DESTDIR, DESTDIR will be set to
# INSTALL_PREFIX. INSTALL_PREFIX has been buggy for a long time. It was
# initially intended to have the same effect as DESTDIR. This effect was,
# however, lost even before it was first released :-( In all released OTP
# versions up to R13B03, INSTALL_PREFIX has behaved as EXTRA_PREFIX do
# today (see below).

ifeq ($(DESTDIR),)
ifneq ($(INSTALL_PREFIX),)
DESTDIR=$(INSTALL_PREFIX)
endif
else
ifneq ($(INSTALL_PREFIX),)
ifneq ($(DESTDIR),$(INSTALL_PREFIX))
$(error Both DESTDIR="$(DESTDIR)" and INSTALL_PREFIX="$(INSTALL_PREFIX)" have been set and have been set differently! Please, only set one of them)
endif
endif
endif

# $ make EXTRA_PREFIX=<...> install
#
# EXTRA_PREFIX behaves exactly as the buggy INSTALL_PREFIX behaved in
# pre R13B04 releases. It adds a prefix to all installation paths which
# will be used by the actuall installation. That is, the installation
# needs to be located at this location when run. This is useful if you
# want to try out the system, running test suites, etc, before doing the
# real install using the configuration you have set up using `configure'.
# A similar thing can be done by overriding `prefix' if only default
# installation directories are used. However, the installation can get
# sprawled out all over the place if the user use `--bindir', `--libdir',
# etc, and it is possible that `prefix' wont have any effect at all. That
# is, it is not at all the same thing as using EXTRA_PREFIX in the
# general case. It is also nice to be able to supply this feature if
# someone should have relied on the old buggy INSTALL_PREFIX.

# The directory in which user executables (ERL_BASE_PUB_FILES) are installed
BINDIR      = $(DESTDIR)$(EXTRA_PREFIX)$(bindir)

#
# Erlang base public files
#
ERL_BASE_PUB_FILES=erl erlc epmd run_erl to_erl dialyzer typer escript ct_run

# ERLANG_INST_LIBDIR is the top directory where the Erlang installation
# will be located when running.
ERLANG_INST_LIBDIR=$(EXTRA_PREFIX)$(erlang_libdir)
ERLANG_INST_BINDIR= $(ERLANG_INST_LIBDIR)/bin

# ERLANG_LIBDIR is the top directory where the Erlang installation is copied
# during installation. If DESTDIR != "", it cannot be run from this location.
ERLANG_LIBDIR     = $(DESTDIR)$(ERLANG_INST_LIBDIR)

# ----------------------------------------------------------------------
# This functionality has been lost along the way... :(
# It could perhaps be nice to reintroduce some day; therefore,
# it is not removed just commented out.

## # The directory in which man pages for above executables are put
## ERL_MAN1DIR      = $(DESTDIR)$(EXTRA_PREFIX)${prefix}/share/man/man1
## ERL_MAN1EXT      = 1

## # The directory in which Erlang private man pages are put. In order
## # not to clutter up the man namespace these are by default put in the
## # Erlang private directory $(ERLANG_LIBDIR)/man (\@erl_mandir\@ is set
## # to $(erlang_libdir)/man). If you want to install the man pages
## # together with the rest give the argument "--disable-erlang-mandir"
## # when you run configure, which will set \@erl_mandir\@ to \@mandir\@.
## #   If you want a special suffix on the manpages set ERL_MANEXT to
## # this suffix, e.g. "erl"
## ERL_MANDIR       = $(DESTDIR)$(EXTRA_PREFIX)@erl_mandir@
## ERL_MANEXT       =

# ----------------------------------------------------------------------

# Must be GNU make!
MAKE		= make

PERL		= /usr/bin/perl

NATIVE_LIBS_ENABLED = 

ifeq ($(NATIVE_LIBS_ENABLED),yes)
HIPE_BOOTSTRAP_EBIN = boot_ebin
else
HIPE_BOOTSTRAP_EBIN = ebin
endif

# This should be set to the target "arch-vendor-os"
TARGET	:= x86_64-apple-darwin19.4.0
include $(ERL_TOP)/make/target.mk
export TARGET
include $(ERL_TOP)/make/otp_default_release_path.mk

BOOTSTRAP_ONLY = no

CROSS_COMPILING = no
ifeq ($(CROSS_COMPILING),yes)
INSTALL_CROSS = -cross
TARGET_HOST=$(shell $(ERL_TOP)/erts/autoconf/config.guess)
else
ifneq ($(DESTDIR),)
INSTALL_CROSS = -cross
else
INSTALL_CROSS = 
endif
TARGET_HOST=
endif

# A BSD compatible install program
INSTALL         = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA    = ${INSTALL} -m 644
MKSUBDIRS       = ${INSTALL} -d

# Program to create symbolic links
LN_S            = ln -s

# Ranlib program, if not needed set to e.g. ":"
RANLIB          = ranlib

# ----------------------------------------------------------------------

# By default we require an Erlang/OTP of the same release as the one
# we cross compile.
ERL_XCOMP_FORCE_DIFFERENT_OTP = no

# ----------------------------------------------------------------------

#
# The directory where at least the primary bootstrap is placed under.
#
# We need to build to view private files in case we are in clearcase;
# therefore, we don't want BOOTSTRAP_TOP changed.
#
# PRIMARY_BOOTSTRAP_TOP would perhaps have been a better name...
#
override BOOTSTRAP_TOP = $(ERL_TOP)/bootstrap
# BOOTSTRAP_SRC_TOP is normally the same as BOOTSTRAP_TOP but
# it is allowed to be changed
BOOTSTRAP_SRC_TOP = $(BOOTSTRAP_TOP)

# Where to install the bootstrap directory.
#
# Typically one might want to set this to a fast local filesystem, or,
# the default, as ERL_TOP
BOOTSTRAP_ROOT = $(ERL_TOP)

# Directories which you need in the path if you wish to run the
# locally built system. (This can be put in front or back of the path
# depending on which system is preferred.)
LOCAL_PATH     = $(ERL_TOP)/erts/bin/$(TARGET):$(ERL_TOP)/erts/bin
ifeq ($(TARGET),win32)
BOOT_PREFIX=$(WIN32_WRAPPER_PATH):$(BOOTSTRAP_ROOT)/bootstrap/bin:
TEST_PATH_PREFIX=$(WIN32_WRAPPER_PATH):$(ERL_TOP)/bin/win32:
else
BOOT_PREFIX=$(BOOTSTRAP_ROOT)/bootstrap/bin:
TEST_PATH_PREFIX=$(ERL_TOP)/bin/$(TARGET_HOST):
endif

# ----------------------------------------------------------------------

# The following is currently only used for determining what to prevent
# usage of during strict install or release.
include $(ERL_TOP)/make/$(TARGET)/otp_ded.mk
CC	= gcc
LD	= ld
CXX	= g++

IBIN_DIR	= $(ERL_TOP)/ibin
#
# If $(OTP_STRICT_INSTALL) equals `yes' we prefix the PATH with $(IBIN_DIR)
# when doing `release' or `install'. This directory contains `erlc', `gcc',
# `ld' etc, that unconditionally will fail if used. This is used during the
# daily builds in order to pick up on things being erroneously built during
# the `release' and `install' phases.
#
INST_FORBID	= gcc g++ cc c++ cxx cl gcc.sh cc.sh ld ld.sh 
INST_FORBID	+= javac.sh javac guavac gcj jikes bock
INST_FORBID	+= $(notdir $(CC)) $(notdir $(LD)) $(notdir $(CXX))
INST_FORBID	+= $(notdir $(DED_CC)) $(notdir $(DED_LD))
INST_FORBID 	+= $(ERL_BASE_PUB_FILES)
IBIN_FILES	= $(addprefix $(IBIN_DIR)/,$(sort $(INST_FORBID))) # sort will
                                                                   # remove
                                                                   # duplicates

ifeq ($(OTP_STRICT_INSTALL),yes)

INST_PATH_PREFIX=$(IBIN_DIR):
INST_DEP	= strict_install
ifneq ($(CROSS_COMPILING),yes)
INST_DEP	+= strict_install_all_bootstraps
endif

else # --- Normal case, i.e., not strict install ---

#
# By default we allow build during install and release phase; therefore,
# make sure that the bootstrap system is available in the path.
#
INST_PATH_PREFIX=$(BOOT_PREFIX)
# If cross compiling `erlc', in path might have be used; therefore,
# avoid triggering a bootstrap build...
INST_DEP	=
ifneq ($(CROSS_COMPILING),yes)
INST_DEP	+= all_bootstraps
endif

endif # --- Normal case, i.e., not strict install ---

# ----------------------------------------------------------------------
# Fix up RELEASE_ROOT/TESTROOT havoc
ifeq ($(RELEASE_ROOT),)
ifneq ($(TESTROOT),)
RELEASE_ROOT = $(TESTROOT)
endif
endif


# ----------------------------------------------------------------------

# A default for the release_tests, not same target dir as release.
# More TESTROOT havoc...
ifeq ($(TESTSUITE_ROOT),)
ifneq ($(TESTROOT),)
TESTSUITE_ROOT = $(TESTROOT)
else
TESTSUITE_ROOT = $(ERL_TOP)/release/tests
endif
endif

#
# The steps to build a working system are:
#   * build an emulator
#   * setup the erl and erlc program in bootstrap/bin
#   * optionally run pgo and build optimized emulator
#   * build additional compilers and copy them into bootstrap/lib
#   * use the bootstrap erl and erlc to build all the libs
#

.PHONY: all bootstrap all_bootstraps

ifneq ($(CROSS_COMPILING),yes)
# Not cross compiling

ifeq ($(BOOTSTRAP_ONLY),yes)
all: bootstrap check_dev_rt_dep
else
# The normal case; not cross compiling, and not bootstrap only build.
all: bootstrap libs local_setup check_dev_rt_dep
endif

else
# Cross compiling

all: cross_check_erl depend build_erl_interface \
     emulator libs start_scripts check_dev_rt_dep

endif

cross_check_erl:
	@PATH=$(BOOT_PREFIX)"$${PATH}" $(ERL_TOP)/make/cross_check_erl \
           -target $(TARGET) -otp $(OTP) -erl_top $(ERL_TOP) \
           -force $(ERL_XCOMP_FORCE_DIFFERENT_OTP)

is_cross_configured:
	@echo no

target_configured:
	@echo x86_64-apple-darwin19.4.0

erlang_inst_libdir_configured:
	@echo $(ERLANG_INST_LIBDIR)

bootstrap: depend all_bootstraps

check_dev_rt_dep:
	@if `grep DEVELOPMENT "$(ERL_TOP)/make/otp_version_tickets" 1>/dev/null 2>&1 \
	  || grep TESTING "$(ERL_TOP)/make/otp_version_tickets" 1>/dev/null 2>&1`; then \
	  LANG=C "$(PERL)" "$(ERL_TOP)/make/fixup_development_runtime_dependencies" "$(ERL_TOP)"; \
	fi

ifeq ($(OTP_STRICT_INSTALL),yes)

.PHONY: strict_install_all_bootstraps

strict_install_all_bootstraps:
	$(MAKE) BOOT_PREFIX=$(INST_PATH_PREFIX) OTP_STRICT_INSTALL=$(OTP_STRICT_INSTALL) all_bootstraps

endif

# With all bootstraps we mean all bootstrapping that is done when
# the system is delivered in open source, the primary
# bootstrap is not included, it requires a pre built emulator...
ifeq ($(OTP_TINY_BUILD),true)
all_bootstraps: build_erl_interface emulator bootstrap_setup \
     tiny_secondary_bootstrap_build tiny_secondary_bootstrap_copy
else
all_bootstraps: build_erl_interface emulator \
     bootstrap_setup \
     secondary_bootstrap_build secondary_bootstrap_copy \
     tertiary_bootstrap_build tertiary_bootstrap_copy
endif

.PHONY: build_erl_interface

build_erl_interface:
	$(make_verbose)cd lib/erl_interface && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) $(TYPE)
#
# Use these targets when you want to use the erl and erlc
# binaries in your PATH instead of those created from the
# pre-compiled Erlang modules under bootstrap/.
#
noboot:
	$(MAKE) USE_PGO=false BOOT_PREFIX= build_erl_interface emulator libs local_setup

noboot_install:
	$(MAKE) USE_PGO=false BOOT_PREFIX= install

.PHONY: release release_docs

release: $(INST_DEP)
ifeq ($(OTP_SMALL_BUILD),true)
	cd $(ERL_TOP)/lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(INST_PATH_PREFIX)"$${PATH}" \
	    $(MAKE) TESTROOT="$(RELEASE_ROOT)" release
else
	cd $(ERL_TOP)/lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(INST_PATH_PREFIX)"$${PATH}" \
	    $(MAKE) BUILD_ALL=1 TESTROOT="$(RELEASE_ROOT)" release
endif
	cd $(ERL_TOP)/erts && \
	  ERL_TOP=$(ERL_TOP) PATH=$(INST_PATH_PREFIX)"$${PATH}" \
	    $(MAKE) BUILD_ALL=1 PROFILE=$(PROFILE) TESTROOT="$(RELEASE_ROOT)" release
ifeq ($(RELEASE_ROOT),)
	$(INSTALL_DATA) "$(ERL_TOP)/OTP_VERSION" "$(OTP_DEFAULT_RELEASE_PATH)/releases/22"
else
	$(INSTALL_DATA) "$(ERL_TOP)/OTP_VERSION" "$(RELEASE_ROOT)/releases/22"
endif

# ---------------------------------------------------------------
# Target only used when building commercial ERTS patches
# ---------------------------------------------------------------

release_docs docs: doc_bootstrap_build doc_bootstrap_copy mod2app 
ifeq ($(OTP_SMALL_BUILD),true)
	cd $(ERL_TOP)/lib && \
	  PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	  $(MAKE) TESTROOT="$(RELEASE_ROOT)" DOCGEN=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen $@
else
	cd $(ERL_TOP)/lib && \
	  PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	  $(MAKE) BUILD_ALL=1 TESTROOT="$(RELEASE_ROOT)" DOCGEN=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen $@
endif
	cd $(ERL_TOP)/erts && \
	  PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	  $(MAKE) BUILD_ALL=1 TESTROOT="$(RELEASE_ROOT)" DOCGEN=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen $@
	cd $(ERL_TOP)/system/doc && \
	  PATH=$(BOOT_PREFIX)"$${PATH}" \
	  ERL_TOP=$(ERL_TOP) $(MAKE) TESTROOT="$(RELEASE_ROOT)" DOCGEN=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen $@
ifneq  ($(OTP_SMALL_BUILD),true)
	test -f $(ERL_TOP)/make/otp_doc_built || echo "OTP doc built" > $(ERL_TOP)/make/otp_doc_built
endif

xmllint: docs
	PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	$(MAKE) -C erts/ $@
ifeq ($(OTP_SMALL_BUILD),true)
	PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	$(MAKE) -C lib/ $@
else
	PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	$(MAKE) BUILD_ALL=1 -C lib/ $@
	PATH=$(BOOT_PREFIX)"$${PATH}" ERL_TOP=$(ERL_TOP) \
	$(MAKE) -C system/doc $@
endif

mod2app: $(ERL_TOP)/make/$(TARGET)/mod2app.xml

$(ERL_TOP)/make/$(TARGET)/mod2app.xml: erts/doc/src/Makefile lib/*/doc/src/Makefile 
	PATH=$(BOOT_PREFIX)"$${PATH}" escript $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/priv/bin/xref_mod_app.escript -topdir $(ERL_TOP) -outfile $(ERL_TOP)/make/$(TARGET)/mod2app.xml

# ----------------------------------------------------------------------
ERLANG_EARS=$(BOOTSTRAP_ROOT)/bootstrap/erts
ELINK=$(BOOTSTRAP_ROOT)/bootstrap/erts/bin/elink
BOOT_BINDIR=$(BOOTSTRAP_ROOT)/bootstrap/erts/bin
BEAM_EVM=$(ERL_TOP)/bin/$(TARGET)/beam_evm
BOOTSTRAP_COMPILER  =  $(BOOTSTRAP_TOP)/primary_compiler

# otp.mk is only used to figure out if we are doing PGO or not
include $(ERL_TOP)/make/$(TARGET)/otp.mk

.PHONY: emulator libs kernel stdlib compiler hipe syntax_tools preloaded

ifeq ($(USE_PGO), true)
PROFILE=use
PROFILE_EMU_DEPS=emulator_profile_generate bootstrap_setup
emulator_profile_generate:
	$(make_verbose)cd erts && ERL_TOP=$(ERL_TOP) $(MAKE) NO_START_SCRIPTS=true $(TYPE) FLAVOR=$(FLAVOR) PROFILE=generate
else
PROFILE=
PROFILE_EMU_DEPS=
endif

emulator: $(PROFILE_EMU_DEPS)
	$(make_verbose)cd erts && ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
	  $(MAKE) NO_START_SCRIPTS=true $(TYPE) FLAVOR=$(FLAVOR) PROFILE=$(PROFILE)

libs:
ifeq ($(OTP_SMALL_BUILD),true)
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) $(TYPE)
else
ifeq ($(OTP_TINY_BUILD),true)
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) opt TINY_BUILD=true
else
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) $(TYPE) BUILD_ALL=true
	$(V_at)test -f $(ERL_TOP)/make/otp_built || echo "OTP built" > $(ERL_TOP)/make/otp_built
endif
endif

APPS=$(patsubst $(ERL_TOP)/lib/%/doc,%,$(wildcard $(ERL_TOP)/lib/*/doc))

$(APPS):
	$(make_verbose)cd lib/$@ && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) $(TYPE) BUILD_ALL=true

preloaded:
	$(make_verbose)cd erts/preloaded/src && \
	ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) opt BUILD_ALL=true	

dep depend:
	$(make_verbose)
	$(V_at)test X"$$ERTS_SKIP_DEPEND" = X"true" || (cd erts/emulator && ERL_TOP=$(ERL_TOP) $(MAKE) generate)
	$(V_at)test X"$$ERTS_SKIP_DEPEND" = X"true" || (cd erts/emulator && ERL_TOP=$(ERL_TOP) $(MAKE) depend)
	$(V_at)test X"$$ERTS_SKIP_DEPEND" = X"true" || (cd erts/lib_src && ERL_TOP=$(ERL_TOP) $(MAKE) depend)

# Creates "erl" and "erlc" in bootstrap/bin which uses the precompiled 
# libraries in the bootstrap directory

.PHONY: bootstrap_setup_target

# ----------------------------------------------------------------------
# Bootstraps... 
# ----------------------------------------------------------------------
ifeq ($(TARGET),win32)

# Sleep for 11 seconds if we use ERLC server in order to let it
# terminate before we remove the bootstrap files
bootstrap_setup: check_recreate_primary_bootstrap bootstrap_setup_target
	-$(V_at)(test X"$$ERLC_USE_SERVER" = X"yes" || test X"$$ERLC_USE_SERVER" = X"true") && sleep 11
	@rm -f $(BOOTSTRAP_ROOT)/bootstrap/bin/erl.exe \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/erlc.exe \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/escript.exe \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/erl.ini \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/beam.dll
	make_bootstrap_ini.sh $(BOOTSTRAP_ROOT)/bootstrap \
		$(ERL_TOP)/bin/$(TARGET)
	@cp $(ERL_TOP)/bin/$(TARGET)/erlc.exe \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/erlc.exe
	@cp $(ERL_TOP)/bin/$(TARGET)/erl.exe \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/erl.exe
	@cp $(ERL_TOP)/bin/$(TARGET)/escript.exe \
		$(BOOTSTRAP_ROOT)/bootstrap/bin/escript.exe
else
bootstrap_setup: check_recreate_primary_bootstrap bootstrap_setup_target $(BOOTSTRAP_ROOT)/bootstrap/bin/erl $(BOOTSTRAP_ROOT)/bootstrap/bin/erlc $(BOOTSTRAP_ROOT)/bootstrap/bin/escript

$(BOOTSTRAP_ROOT)/bootstrap/bin/erl: $(ERL_TOP)/erts/etc/unix/erl.src.src $(BOOTSTRAP_ROOT)/bootstrap/target
	@rm -f $(BOOTSTRAP_ROOT)/bootstrap/bin/erl 
	@sed	-e "s;%FINAL_ROOTDIR%;$(BOOTSTRAP_ROOT)/bootstrap;"   \
		-e "s;\$$ROOTDIR/erts-.*/bin;$(ERL_TOP)/bin/$(TARGET);"    \
		-e "s;EMU=.*;EMU=beam$(TYPEMARKER);" \
	        $(ERL_TOP)/erts/etc/unix/erl.src.src > \
			$(BOOTSTRAP_ROOT)/bootstrap/bin/erl
	@chmod 755 $(BOOTSTRAP_ROOT)/bootstrap/bin/erl

$(BOOTSTRAP_ROOT)/bootstrap/bin/erlc: $(ERL_TOP)/bin/$(TARGET)/erlc $(BOOTSTRAP_ROOT)/bootstrap/target
	@rm -f $(BOOTSTRAP_ROOT)/bootstrap/bin/erlc
	@cp $(ERL_TOP)/bin/$(TARGET)/erlc $(BOOTSTRAP_ROOT)/bootstrap/bin/erlc
	@chmod 755 $(BOOTSTRAP_ROOT)/bootstrap/bin/erlc

$(BOOTSTRAP_ROOT)/bootstrap/bin/escript: $(ERL_TOP)/bin/$(TARGET)/escript $(BOOTSTRAP_ROOT)/bootstrap/target
	@rm -f $(BOOTSTRAP_ROOT)/bootstrap/bin/escript
	@cp $(ERL_TOP)/bin/$(TARGET)/escript $(BOOTSTRAP_ROOT)/bootstrap/bin/escript
	@chmod 755 $(BOOTSTRAP_ROOT)/bootstrap/bin/escript
endif

bootstrap_setup_target:
	@{ test -r $(BOOTSTRAP_ROOT)/bootstrap/target && \
	   test $(TARGET) = `cat $(BOOTSTRAP_ROOT)/bootstrap/target`; } || \
	 echo $(TARGET) > $(BOOTSTRAP_ROOT)/bootstrap/target

tiny_secondary_bootstrap_build:
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) opt SECONDARY_BOOTSTRAP=true TINY_BUILD=true

secondary_bootstrap_build:
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) opt SECONDARY_BOOTSTRAP=true

tiny_secondary_bootstrap_copy:
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include ; fi
	$(V_at)for x in lib/parsetools/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)for x in lib/parsetools/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/include ; fi
	$(V_at)for x in lib/sasl/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done

secondary_bootstrap_copy:
	$(make_verbose)
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/hipe ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/hipe ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/hipe/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/hipe/ebin ; fi
	$(V_at)for x in lib/hipe/$(HIPE_BOOTSTRAP_EBIN)/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/hipe/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include ; fi
	$(V_at)for x in lib/parsetools/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp lib/parsetools/ebin/*.beam $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/ebin
	$(V_at)for x in lib/parsetools/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp -f lib/parsetools/include/*.hrl $(BOOTSTRAP_ROOT)/bootstrap/lib/parsetools/include
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1 ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1 ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/src ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/src ; fi
	$(V_at)for x in lib/asn1/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp lib/asn1/ebin/*.beam $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/ebin
	$(V_at)for x in lib/asn1/src/*.[eh]rl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/src/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp -f lib/asn1/src/*.erl lib/asn1/src/*.hrl $(BOOTSTRAP_ROOT)/bootstrap/lib/asn1/src
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl/include ; fi
	$(V_at)for x in lib/xmerl/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done

tertiary_bootstrap_build:
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) opt TERTIARY_BOOTSTRAP=true

tertiary_bootstrap_copy:
	$(make_verbose)
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp/include ; fi
	$(V_at)for x in lib/snmp/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/snmp/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp lib/snmp/ebin/*.beam $(BOOTSTRAP_ROOT)/bootstrap/lib/snmp/ebin
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/include ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/wx ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/wx ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/wx/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/wx/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/wx/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/wx/include ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/common_test ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/common_test ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/common_test/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/common_test/include ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/runtime_tools ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/runtime_tools ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/runtime_tools/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/runtime_tools/include ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_interface ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_interface ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_interface/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_interface/include ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/ ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/ ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson/otp ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson/otp ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson/otp/erlang ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson/otp/erlang ; fi
	$(V_at)for x in lib/sasl/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp lib/sasl/ebin/*.beam $(BOOTSTRAP_ROOT)/bootstrap/lib/sasl/ebin
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/syntax_tools ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/syntax_tools ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/syntax_tools/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/syntax_tools/ebin ; fi
	$(V_at)for x in lib/syntax_tools/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/syntax_tools/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)for x in lib/wx/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/wx/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#       copy wx_object to remove undef behaviour warnings
	$(V_at)for x in lib/wx/ebin/wx_object.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/wx/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done

#	copy test includes to be able to compile tests with bootstrap compiler
	$(V_at)for x in lib/common_test/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/common_test/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done

#	copy runtime_tool includes to be able to compile with include_lib
	$(V_at)for x in lib/runtime_tools/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/runtime_tools/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	copy erl_interface includes
	$(V_at)for x in lib/erl_interface/include/*.h; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_interface/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	copy jinterface priv directory
	$(V_at)for x in lib/jinterface/priv/OtpErlang.jar; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)for x in lib/jinterface/priv/com/ericsson/otp/erlang/*; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/jinterface/priv/com/ericsson/otp/erlang/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#	$(V_at)cp lib/syntax_tools/ebin/*.beam $(BOOTSTRAP_ROOT)/bootstrap/lib/syntax_tools/ebin

doc_bootstrap_build:
	$(make_verbose)cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) opt DOC_BOOTSTRAP=true

doc_bootstrap_copy:
	$(make_verbose)
#       XMERL
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl/ebin ; fi
	$(V_at)for x in lib/xmerl/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/xmerl/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#       xmerl/include already copied in secondary bootstrap
#       EDOC
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/edoc ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/edoc ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/edoc/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/edoc/ebin ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/edoc/include ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/edoc/include ; fi
	$(V_at)for x in lib/edoc/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/edoc/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)for x in lib/edoc/include/*.hrl; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/edoc/include/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
#       ERL_DOCGEN
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen ; fi
	$(V_at)if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/ebin ; then mkdir $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/ebin ; fi
	$(V_at)for x in lib/erl_docgen/ebin/*.beam; do \
		BN=`basename $$x`; \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/ebin/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	done
	$(V_at)for d in priv priv/bin priv/css priv/dtd priv/dtd_html_entities priv/dtd_man_entities priv/images priv/js priv/js/flipmenu priv/xsl; do \
	  if test ! -d $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/$$d ; then mkdir -p $(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/$$d ; fi; \
	  for x in lib/erl_docgen/$$d/*; do \
	    BN=`basename $$x`; \
	    if test ! -d lib/erl_docgen/$$d/$$BN ; then \
		TF=$(BOOTSTRAP_ROOT)/bootstrap/lib/erl_docgen/$$d/$$BN; \
		test -f  $$TF && \
		test '!' -z "`find $$x -newer $$TF -print`" && \
			cp $$x $$TF; \
		test '!' -f $$TF && \
			cp $$x $$TF; \
		true; \
	   fi; \
	  done; \
	done

.PHONY: check_recreate_primary_bootstrap recreate_primary_bootstrap


#
# If the source is a prebuilt delivery, no $(ERL_TOP)/bootstrap/lib
# directory will exist. All applications part of the primary bootstrap
# are delivered prebuilt though. If it is a prebuilt delivery we need
# to recreate the primary bootstrap, from the prebuilt result.
#
# A prebuild delivery always contain a $(ERL_TOP)/prebuilt.files file.
# If no such file exists, we wont try to recreate the primary bootstrap,
# since it will just fail producing anything useful.
#

check_recreate_primary_bootstrap:
	@if test -f $(ERL_TOP)/prebuilt.files ; then \
	  if test ! -d $(ERL_TOP)/bootstrap/lib ; then \
	    $(ERL_TOP)/otp_build save_bootstrap ; \
	  fi ; \
	fi

#
# recreate_primary_bootstrap assumes that if $(ERL_TOP)/prebuilt.files
# exist, all build results needed already exist in the application specific
# directories of all applications part of the primary bootstrap.
#
recreate_primary_bootstrap:
	$(V_at)$(ERL_TOP)/otp_build save_bootstrap

# The first bootstrap build is rarely (never) used in open source, it's
# used to build the shipped bootstrap directory. The Open source bootstrap 
# stages start with secondary bootstrap.
#
# These are the ones used, the other ones (prefixed with old_) are for BC.

# These modules should stay in the kernel directory to make building
# of the emulator possible

.PHONY: primary_bootstrap						\
	primary_bootstrap_build						\
	primary_bootstrap_compiler					\
	primary_bootstrap_mkdirs					\
	primary_bootstrap_copy

primary_bootstrap:
	@echo "=== Building a bootstrap compiler in $(BOOTSTRAP_ROOT)/bootstrap"
	$(V_at)$(MAKE) BOOTSTRAP_ROOT=$(BOOTSTRAP_ROOT) \
		ERL_TOP=$(ERL_TOP) \
		bootstrap_clean
	$(V_at)cd $(ERL_TOP) && \
		$(MAKE) TESTROOT=$(BOOTSTRAP_TOP) \
		BOOTSTRAP_TOP=$(BOOTSTRAP_TOP) \
		primary_bootstrap_build
	$(V_at)cd $(ERL_TOP) && \
		$(MAKE) TESTROOT=$(BOOTSTRAP_TOP) \
		BOOTSTRAP_TOP=$(BOOTSTRAP_TOP) \
		primary_bootstrap_copy
	$(V_at)cd $(ERL_TOP)/erts/start_scripts && \
		$(MAKE) TESTROOT=$(BOOTSTRAP_TOP) \
		BOOTSTRAP_TOP=$(BOOTSTRAP_TOP) bootstrap_scripts
	$(V_at)test $(BOOTSTRAP_ROOT) = $(ERL_TOP) \
		|| $(ERL_TOP)/otp_build \
			copy_primary_bootstrap \
			$(BOOTSTRAP_TOP) \
			$(BOOTSTRAP_ROOT)

primary_bootstrap_build: primary_bootstrap_mkdirs primary_bootstrap_compiler \
  primary_bootstrap_stdlib
	$(make_verbose)cd lib && $(MAKE) ERLC_FLAGS='-pa $(BOOTSTRAP_COMPILER)/ebin' \
		BOOTSTRAP_TOP=$(BOOTSTRAP_TOP) \
		BOOTSTRAP=1 opt

primary_bootstrap_compiler: 
	$(make_verbose)cd lib/compiler && $(MAKE) \
		BOOTSTRAP_TOP=$(BOOTSTRAP_TOP) \
		BOOTSTRAP_COMPILER=$(BOOTSTRAP_COMPILER) \
		BOOTSTRAP=1 \
		opt

primary_bootstrap_stdlib: 
	$(make_verbose)cd lib/stdlib/src && $(MAKE) \
		BOOTSTRAP_COMPILER=$(BOOTSTRAP_COMPILER) \
		primary_bootstrap_compiler

primary_bootstrap_mkdirs:
	$(make_verbose)
	$(V_at)test -d $(BOOTSTRAP_COMPILER)/egen \
		|| mkdir -p $(BOOTSTRAP_COMPILER)/egen
	$(V_at)test -d $(BOOTSTRAP_COMPILER)/ebin \
		|| mkdir -p $(BOOTSTRAP_COMPILER)/ebin
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/kernel/egen \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/kernel/egen 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/kernel/ebin \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/kernel/ebin 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/kernel/include \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/kernel/include 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/stdlib/egen \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/stdlib/egen 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/stdlib/ebin \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/stdlib/ebin 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/stdlib/include \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/stdlib/include 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/compiler/egen \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/compiler/egen 
	$(V_at)test -d $(BOOTSTRAP_TOP)/lib/compiler/ebin \
		|| mkdir -p $(BOOTSTRAP_TOP)/lib/compiler/ebin 

primary_bootstrap_copy:
	$(make_verbose)
	$(V_at)cp -f lib/kernel/include/*.hrl $(BOOTSTRAP_TOP)/lib/kernel/include
	$(V_at)cp -f lib/stdlib/include/*.hrl $(BOOTSTRAP_TOP)/lib/stdlib/include

# To remove modules left by the bootstrap building, but leave (restore)
# the modules in kernel which are needed for an emulator build
KERNEL_PRELOAD    = erl_init init erl_prim_loader prim_inet prim_file zlib prim_zip erlang erts_code_purger
KERNEL_PRELOAD_BEAMS=$(KERNEL_PRELOAD:%=$(BOOTSTRAP_TOP)/lib/kernel/ebin/%.beam)

start_scripts:
	@cd erts/start_scripts \
	     && ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" $(MAKE) script

# Creates "erl" and "erlc" scripts in bin/erl which uses the libraries in lib
local_setup:
	@rm -f bin/erl bin/erlc bin/cerl
	@cd erts && \
		ERL_TOP=$(ERL_TOP) PATH=$(BOOT_PREFIX)"$${PATH}" \
		$(MAKE) local_setup



# ----------------------------------------------------------------------
# Build tests
# ---------------------------------------------------------------------

TEST_DIRS := \
	lib/common_test/test_server \
	$(wildcard lib/*/test) \
	erts/test \
	erts/epmd/test \
	erts/emulator/test

# Any applications listed in SKIP-APPLICATIONS should be skipped
SKIP_FILE := $(wildcard lib/SKIP-APPLICATIONS)
SKIP_TEST_DIRS := $(if $(SKIP_FILE),$(foreach APP,$(shell cat $(SKIP_FILE)),lib/$(APP)/test))
TEST_DIRS := $(filter-out $(SKIP_TEST_DIRS),$(TEST_DIRS))

.PHONY: tests release_tests $(TEST_DIRS)

tests release_tests: $(TEST_DIRS)

$(TEST_DIRS):
	if test -f $@/Makefile; then \
	    (cd $@; $(MAKE) TESTROOT="$(TESTSUITE_ROOT)" \
	    PATH=$(TEST_PATH_PREFIX)$(BOOT_PREFIX)"$${PATH}" release_tests) || exit $$?; \
	fi

#
# Install
#
# Order is important here, don't change it!
#
INST_DEP += install.dirs install.emulator install.libs install.Install install.otp_version install.bin

install: $(INST_DEP)

install-docs: 
	ERL_TOP=$(ERL_TOP) INSTALLROOT="$(ERLANG_LIBDIR)" PATH=$(BOOT_PREFIX)"$${PATH}" \
	$(MAKE) RELEASE_ROOT="$(ERLANG_LIBDIR)" release_docs


install.emulator:
	cd erts && \
	  ERL_TOP=$(ERL_TOP) PATH=$(INST_PATH_PREFIX)"$${PATH}" \
	  $(MAKE) PROFILE=$(PROFILE) TESTROOT="$(ERLANG_LIBDIR)" release

install.libs:
ifeq ($(OTP_SMALL_BUILD),true)
	cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(INST_PATH_PREFIX)"$${PATH}" \
	  $(MAKE) TESTROOT="$(ERLANG_LIBDIR)" release 
else
	cd lib && \
	  ERL_TOP=$(ERL_TOP) PATH=$(INST_PATH_PREFIX)"$${PATH}" \
	  $(MAKE) TESTROOT="$(ERLANG_LIBDIR)" BUILD_ALL=true release
endif

install.Install:
	(cd "$(ERLANG_LIBDIR)" \
	 && ./Install $(INSTALL_CROSS) -minimal "$(ERLANG_INST_LIBDIR)")

install.otp_version:
ifeq ($(ERLANG_LIBDIR),)
	$(INSTALL_DATA) "$(ERL_TOP)/OTP_VERSION" "$(OTP_DEFAULT_RELEASE_PATH)/releases/22"
else
	$(INSTALL_DATA) "$(ERL_TOP)/OTP_VERSION" "$(ERLANG_LIBDIR)/releases/22"
endif

#
# Install erlang base public files
#

install.bin:
	@ DESTDIR="$(DESTDIR)" EXTRA_PREFIX="$(EXTRA_PREFIX)"		\
	  LN_S="$(LN_S)" BINDIR_SYMLINKS="$(BINDIR_SYMLINKS)"  		\
		$(ERL_TOP)/make/install_bin				\
			--bindir "$(bindir)"				\
			--erlang-bindir "$(erlang_bindir)"		\
			--exec-prefix "$(exec_prefix)"			\
			$(ERL_BASE_PUB_FILES)

#
# Directories needed before we can install
#
install.dirs:
	test -d "$(BINDIR)" || ${MKSUBDIRS} "$(BINDIR)"
	${MKSUBDIRS} "$(ERLANG_LIBDIR)"
	${MKSUBDIRS} "$(ERLANG_LIBDIR)/usr/lib"

.PHONY: strict_install

strict_install: $(IBIN_DIR) $(IBIN_FILES)

$(IBIN_FILES): $(ERL_TOP)/make/unexpected_use
	rm -f $@
	(cd $(dir $@) && $(LN_S) $(ERL_TOP)/make/unexpected_use $(notdir $@))

$(IBIN_DIR):
	$(MKSUBDIRS) $@

# ----------------------------------------------------------------------

.PHONY: clean eclean bootstrap_root_clean bootstrap_clean

#
# Clean targets
#

clean: check_recreate_primary_bootstrap
	rm -f *~ *.bak config.log config.status prebuilt.files ibin/*
	cd erts && ERL_TOP=$(ERL_TOP) $(MAKE) clean
	cd lib  && ERL_TOP=$(ERL_TOP) $(MAKE) clean BUILD_ALL=true

distclean: clean
	find . -type f -name SKIP              -print | xargs $(RM)
	find . -type f -name SKIP-APPLICATIONS -print | xargs $(RM)

#
# Just wipe out emulator, not libraries
#

eclean:
	cd erts && ERL_TOP=$(ERL_TOP) $(MAKE) clean

#
# Clean up bootstrap
#

bootstrap_root_clean:
	$(make_verbose)
	$(V_at)rm -f $(BOOTSTRAP_ROOT)/bootstrap/lib/*/ebin/*.beam
	$(V_at)rm -f $(BOOTSTRAP_ROOT)/bootstrap/lib/*/include/*.hrl
	$(V_at)rm -f $(BOOTSTRAP_ROOT)/bootstrap/bin/*.*

# $(ERL_TOP)/bootstrap *should* equal $(BOOTSTRAP_TOP)
#
# We use $(ERL_TOP)/bootstrap instead of $(BOOTSTRAP_TOP) here as an
# extra safety precaution (we would really make a mess if
# $(BOOTSTRAP_TOP) for some reason should be empty).
bootstrap_clean:
	$(make_verbose)
	$(V_at)rm -f $(ERL_TOP)/bootstrap/lib/*/ebin/*.beam
	$(V_at)rm -f $(ERL_TOP)/bootstrap/lib/*/ebin/*.app
	$(V_at)rm -f $(ERL_TOP)/bootstrap/lib/*/egen/*
	$(V_at)rm -f $(ERL_TOP)/bootstrap/lib/*/include/*.hrl
	$(V_at)rm -f $(ERL_TOP)/bootstrap/primary_compiler/ebin/*
	$(V_at)rm -f $(ERL_TOP)/bootstrap/primary_compiler/egen/*
	$(V_at)rm -f $(ERL_TOP)/bootstrap/bin/*.*
	$(V_at)rm -f $(KERNEL_PRELOAD:%=$(ERL_TOP)/lib/kernel/ebin/%.beam)
	$(V_at)test $(BOOTSTRAP_ROOT) = $(ERL_TOP) \
		|| $(MAKE) BOOTSTRAP_ROOT=$(BOOTSTRAP_ROOT) bootstrap_root_clean

# ----------------------------------------------------------------------