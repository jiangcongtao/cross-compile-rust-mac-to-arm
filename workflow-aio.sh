#!/usr/bin/env bash
set -e
# -*- coding: utf-8 -*-
# https://chacin.dev/blog/cross-compiling-rust-for-the-raspberry-pi/
# First, execute the following
# sudo port install sshpass

BINARY=$(cat Cargo.toml | grep "^name" | cut -d "=" -f2 | sed 's/^[" ]*//;s/[" ]*$//')
PI_IP=192.168.1.14 # Be sure to change this!
MUSLCC_DIR=~/musl-cc

TARGET=arm-unknown-linux-musleabi # OK, Pi 2/3/4
TARGET_ARCH_ABI=arm-linux-musleabi
CROSS_TC_FILE_BASENAME=${TARGET_ARCH_ABI}-cross

# TARGET=arm-unknown-linux-musleabihf # OK, Pi 2/3/4
# TARGET_ARCH_ABI=arm-linux-musleabihf
# CROSS_TC_FILE_BASENAME=${TARGET_ARCH_ABI}-cross

# Error: dyld: Library not loaded: /usr/local/opt/isl/lib/libisl.22.dylib
# TARGET=armv7-unknown-linux-musleabihf # OK, Pi 2/3/4
# TARGET_ARCH_ABI=armv7l-linux-musleabihf
# CROSS_TC_FILE_BASENAME=${TARGET_ARCH_ABI}-cross

# CROSS_TC_URL=https://lisa.musl.cc/9.2.1/${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_URL=https://mac.musl.cc/${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_FILE_TGZ=${CROSS_TC_FILE_BASENAME}.tgz
CROSS_TC_BASE_DIR=${MUSLCC_DIR}/${CROSS_TC_FILE_BASENAME}
CROSS_TC_TARGET_LD=${TARGET_ARCH_ABI}-ld
CROSS_TC_TARGET_CC=${TARGET_ARCH_ABI}-cc

CARGO_CONFIG_DIR=.cargo
BUILD_MODE=release

CC=${CROSS_TC_BASE_DIR}/bin/${CROSS_TC_TARGET_CC}
CFLAGS="-march=armv6 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe"

echo BINARY = ${BINARY}
mkdir -p ${MUSLCC_DIR} ${CARGO_CONFIG_DIR}

cat << EOF > ${CARGO_CONFIG_DIR}/config
[target.${TARGET}]
linker = "${CROSS_TC_TARGET_LD}"
EOF

[ ! -d ${CROSS_TC_BASE_DIR} ] && echo "Downloading ${CROSS_TC_URL} ..." && \
    curl -LO ${CROSS_TC_URL} -o ${MUSLCC_DIR}/${CROSS_TC_FILE_TGZ} && \
    tar xzvf ${MUSLCC_DIR}/${CROSS_TC_FILE_TGZ} -C ${MUSLCC_DIR} && rm ${CROSS_TC_FILE_TGZ}


rustup target add $TARGET

echo CC = ${CC}
# setup linker ld search path
PATH=${CROSS_TC_BASE_DIR}/bin:${PATH}
# build binary
if [ "${BUILD_MODE}" == "release" ]; then
    cargo clean && cargo build --target $TARGET --${BUILD_MODE}
else
    cargo clean && cargo build --target $TARGET
fi

echo "=> Check file info..."
file ./target/$TARGET/${BUILD_MODE}/$BINARY

# upload binary
echo "=> Coping binrary to PI ..."
sshpass -p 'pi@901' scp -r ./target/$TARGET/${BUILD_MODE}/$BINARY pi@$PI_IP:/home/pi

# execute binary
echo "=> Beginning to execute on PI ..."
sshpass -p 'pi@901' ssh pi@$PI_IP "./${BINARY}"