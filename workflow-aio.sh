#!/usr/bin/env bash
set -e
# -*- coding: utf-8 -*-
# https://chacin.dev/blog/cross-compiling-rust-for-the-raspberry-pi/
# First, execute the following
# sudo port install sshpass

BINARY=$(cat Cargo.toml | grep "^name" | cut -d "=" -f2 | sed 's/^[" ]*//;s/[" ]*$//')
PI_IP=192.168.1.14 # Be sure to change this!
TARGET=arm-unknown-linux-musleabi # OK, Pi 2/3/4
# TARGET=arm-unknown-linux-musleabihf # OK,  Pi 2/3/4
#TARGET=arm-unknown-linux-gnueabihf # Pi 0/1
# TARGET=armv7-unknown-linux-musleabi # OK, Pi 2
# TARGET=arm-unknown-linux-musleabihf # OK, Pi 2

MUSLCC_DIR=~/musl-cc
CROSS_TC_FILE_BASENAME=arm-linux-musleabi-cross

CROSS_TC_URL=https://lisa.musl.cc/9.2.1/${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_FILE_TGZ=${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_BASE_DIR=${MUSLCC_DIR}/${CROSS_TC_FILE_BASENAME}
CROSS_TC_TARGET_LD=arm-linux-musleabi-ld
CROSS_TC_TARGET_CC=arm-linux-musleabi-cc
CARGO_CONFIG_DIR=.cargo

CC=${CROSS_TC_BASE_DIR}/bin/${CROSS_TC_TARGET_CC}
CFLAGS="-march=armv6 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe"

echo BINARY = ${BINARY}
mkdir -p ${MUSLCC_DIR} ${CARGO_CONFIG_DIR}

cat << EOF > ${CARGO_CONFIG_DIR}/config
[target.${TARGET}]
linker = "${CROSS_TC_TARGET_LD}"
EOF

[ ! -d ${CROSS_TC_BASE_DIR} ] && echo "Downloading ${CROSS_TC_URL} ..." && \
    curl -LO ${CROSS_TC_URL} && tar xzvf ${CROSS_TC_FILE_TGZ} -C ${MUSLCC_DIR}


rustup target add $TARGET

echo CC = ${CC}
# setup linker ld search path
PATH=${CROSS_TC_BASE_DIR}/bin:${PATH}
# build binary
cargo clean && cargo build --target $TARGET #--release

echo "=> Check file info..."
file ./target/$TARGET/debug/$BINARY

# upload binary
echo "=> Coping binrary to PI ..."
sshpass -p 'pi@901' scp -r ./target/$TARGET/debug/$BINARY pi@$PI_IP:/home/pi

# execute binary
echo "=> Beginning to execute on PI ..."
sshpass -p 'pi@901' ssh pi@$PI_IP "./${BINARY}"