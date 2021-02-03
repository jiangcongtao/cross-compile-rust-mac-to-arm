# Cross-Compile Rust Projects for ARMv7 Pi 2

## Use target `arm-unknown-linux-musleabi`
### Setup
```bash
git clone  https://github.com/sharkdp/bat.git

TOOLCHAIN_TGZ=https://lisa.musl.cc/9.2.1/arm-linux-musleabi-cross.tgz
MUSLCC_DIR=~/musl-cc && mkdir -p ${MUSLCC_DIR} && curl ${TOOLCHAIN_TGZ} | tar zxvvf - -C ${MUSLCC_DIR}

- Need to install isl on Mac OS (WORKAROUND toolchains BUG)
brew install isl

```

### create .cargo/config under project folder (bat) with the following content
```toml
[target.arm-unknown-linux-musleabi]
linker = "arm-linux-musleabi-ld"
```

### Build
```bash
rustup target list | grep arm
rustup target list | grep arm-unknown-linux-musleabi
rustup target add arm-unknown-linux-musleabi

PATH=~/musl-cc/arm-linux-musleabi-cross/bin:${PATH}
CC=~/musl-cc/arm-linux-musleabi-cross/bin/arm-linux-musleabi-cc
CFLAGS="-march=armv6 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe"
cargo clean
cargo build --target arm-unknown-linux-musleabi --release
```

## Use target `armv7-unknown-linux-musleabihf`
### Setup
```bash
git clone  https://github.com/sharkdp/bat.git

TOOLCHAIN_TGZ=https://mac.musl.cc/armv7l-linux-musleabihf-cross.tgz
MUSLCC_DIR=~/musl-cc && mkdir -p ${MUSLCC_DIR} && curl ${TOOLCHAIN_TGZ} | tar zxvvf - -C ${MUSLCC_DIR}
```

### create .cargo/config under project folder (bat) with the following content
```toml
[target.armv7-unknown-linux-musleabihf]
linker = "armv7l-linux-musleabihf-ld"
```

### Build
```bash
rustup target list | grep arm
rustup target list | grep armv7-unknown-linux-musleabihf
rustup target add armv7-unknown-linux-musleabihf

PATH=~/musl-cc/armv7l-linux-musleabihf-cross/bin:${PATH}
CC=~/musl-cc/armv7l-linux-musleabihf-cross/bin/armv7l-linux-musleabihf-cc
CFLAGS="-march=armv6 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe"
cargo clean
cargo build --target armv7-unknown-linux-musleabihf --release
```