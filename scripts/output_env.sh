#! /usr/bin/env sh

# output_env.sh
#
# This file is part of mbed TLS (https://tls.mbed.org)
#
# Copyright (c) 2016, ARM Limited, All Rights Reserved
#
# Purpose
#
# To print out all the relevant information about the development environment.
#
# This includes:
#   - architecture of the system
#   - type and version of the operating system
#   - version of armcc, clang, gcc-arm and gcc compilers
#   - version of libc, clang, asan and valgrind if installed
#   - version of gnuTLS and OpenSSL

print_version()
{
    BIN="$1"
    shift
    ARGS="$1"
    shift
    VARIANT=$1
    shift

    if [ ! -z $VARIANT ]; then
        VARIANT=" ($VARIANT)"
    fi

    if ! `type "$BIN" > /dev/null 2>&1`; then
        echo " * ${BIN##*/}$VARIANT: Not found."
        return 0
    fi

    BIN=`which "$BIN"`
    VERSION_STR=`$BIN $ARGS 2>&1`

    # Apply all filters
    while [ $# -gt 0 ]; do
        FILTER="$1"
        shift
        VERSION_STR=`echo "$VERSION_STR" | $FILTER`
    done

    echo " * ${BIN##*/}$VARIANT: ${BIN} : ${VERSION_STR} "
}

echo "Platform:\n"
if `type "lsb_release" > /dev/null 2>&1`; then
    echo "Linux variant"
    lsb_release -d -c
else
    echo "Unknown Unix variant"
fi

echo

print_version "uname" "-a" ""
echo "\n"
echo "Tool Versions:\n"

if [ "${RUN_ARMCC:-1}" -ne 0 ]; then
    : "${ARMC5_CC:=armcc}"
    print_version "$ARMC5_CC" "--vsn" "" "head -n 2"
    echo

    : "${ARMC6_CC:=armclang}"
    print_version "$ARMC6_CC" "--vsn" "" "head -n 2"
    echo
fi

print_version "arm-none-eabi-gcc" "--version" "" "head -n 1"
echo

print_version "gcc" "--version" "" "head -n 1"
echo

print_version "clang" "--version" "" "head -n 2"
echo

print_version "ldd" "--version" "" "head -n 1"
echo

print_version "valgrind" "--version" ""
echo

print_version "gdb" "--version" "" "head -n 1"
echo

: ${OPENSSL:=openssl}
print_version "$OPENSSL" "version" "default"
echo

if [ -n "${OPENSSL_LEGACY+set}" ]; then
    print_version "$OPENSSL_LEGACY" "version" "legacy"
else
    echo " * openssl (legacy): Not configured."
fi
echo

: ${GNUTLS_CLI:=gnutls-cli}
print_version "$GNUTLS_CLI" "--version" "default" "head -n 1"
echo

: ${GNUTLS_SERV:=gnutls-serv}
print_version "$GNUTLS_SERV" "--version" "default" "head -n 1"
echo

if [ -n "${GNUTLS_LEGACY_CLI+set}" ]; then
    print_version "$GNUTLS_LEGACY_CLI" "--version" "legacy" "head -n 1"
else
     echo " * gnutls-cli (legacy): Not configured."
fi
echo

if [ -n "${GNUTLS_LEGACY_SERV+set}" ]; then
    print_version "$GNUTLS_LEGACY_SERV" "--version" "legacy" "head -n 1"
else
    echo " * gnutls-serv (legacy): Not configured."
fi
echo

echo " * Installed asan versions:"
if `hash dpkg > /dev/null 2>&1` && `dpkg --get-selections|grep libasan > /dev/null` ; then
    dpkg -s libasan5 2> /dev/null | grep -i version
    dpkg -s libasan4 2> /dev/null | grep -i version
    dpkg -s libasan3 2> /dev/null | grep -i version
    dpkg -s libasan2 2> /dev/null | grep -i version
    dpkg -s libasan1 2> /dev/null | grep -i version
    dpkg -s libasan0 2> /dev/null | grep -i version
else
    echo "   Either dpkg not present or no asan versions installed."
fi
echo
