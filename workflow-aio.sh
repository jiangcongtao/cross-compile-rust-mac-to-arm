#!/usr/bin/env bash
set -e
# -*- coding: utf-8 -*-
# https://chacin.dev/blog/cross-compiling-rust-for-the-raspberry-pi/
# First, execute the following
# sudo port install sshpass

# On brand new Linux system, need to install rustup first
# source $HOME/.cargo/env
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


BINARY=$(cat Cargo.toml | grep "^name" | cut -d "=" -f2 | sed 's/^[" ]*//;s/[" ]*$//')
PI_IP=192.168.1.14 # Be sure to change this!
# TARGET=arm-unknown-linux-musleabi # OK, Pi 2/3/4
TARGET=arm-unknown-linux-musleabi # OK,  Pi 2/3/4

# TARGET=armv7-unknown-linux-musleabihf # OK, Pi 2

MUSLCC_DIR=~/musl-cc
TARGET_ARCH_ABI=arm-linux-musleabi
CROSS_TC_FILE_BASENAME=${TARGET_ARCH_ABI}-cross

CROSS_TC_URL=https://mac.musl.cc/${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_FILE_TGZ=${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_BASE_DIR=${MUSLCC_DIR}/${CROSS_TC_FILE_BASENAME}
CROSS_TC_TARGET_LD=${TARGET_ARCH_ABI}-ld
CROSS_TC_TARGET_CC=${TARGET_ARCH_ABI}-cc
CARGO_CONFIG_DIR=.cargo

export CC=${CROSS_TC_BASE_DIR}/bin/${CROSS_TC_TARGET_CC}
# CFLAGS="-march=armv6 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe"
# export CFLAGS="-march=armv6 -mfloat-abi=softfp"
# export LDFLAGS="-Bstatic"

echo BINARY = ${BINARY}
mkdir -p ${MUSLCC_DIR} ${CARGO_CONFIG_DIR}

cat << EOF > ${CARGO_CONFIG_DIR}/config
[target.${TARGET}]
linker = "${CROSS_TC_TARGET_LD}"
# rustflags = ["-C", "target-feature=+crt-static"]
EOF

[ ! -d ${CROSS_TC_BASE_DIR} ] && echo "Downloading ${CROSS_TC_URL} ..." && \
    curl -LO ${CROSS_TC_URL} && tar xzvf ${CROSS_TC_FILE_TGZ} -C ${MUSLCC_DIR} && rm ${CROSS_TC_FILE_TGZ}


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