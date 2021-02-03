#!/usr/bin/env bash
set -e
# -*- coding: utf-8 -*-
# https://chacin.dev/blog/cross-compiling-rust-for-the-raspberry-pi/
# First, execute the following
# sudo port install sshpass
# brew install arm-linux-gnueabihf-binutils
# rustup target add armv7-unknown-linux-gnueabihf

# rustup target add armv7-unknown-linux-musleabi
# cargo build --target=armv7-unknown-linux-musleabi

# rustup target add arm-unknown-linux-gnueabihf


BINARY=hello
PI_IP=192.168.1.14 # Be sure to change this!
# TARGET=arm-unknown-linux-musleabi # OK, Pi 2/3/4
# TARGET=arm-unknown-linux-musleabihf # OK,  Pi 2/3/4
#TARGET=arm-unknown-linux-gnueabihf # Pi 0/1
# TARGET=armv7-unknown-linux-musleabi # OK, Pi 2
TARGET=arm-unknown-linux-musleabihf # OK, Pi 2

# build binary
cargo build --target $TARGET

echo "=> Check file info..."
file ./target/$TARGET/debug/$BINARY

# upload binary
echo "=> Coping binrary to PI ..."
sshpass -p 'pi@901' scp -r ./target/$TARGET/debug/$BINARY pi@$PI_IP:/home/pi

# execute binary
echo "=> Beginning to execute on PI ..."
sshpass -p 'pi@901' ssh pi@$PI_IP "./${BINARY}"