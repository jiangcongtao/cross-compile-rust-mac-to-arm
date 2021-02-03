# Cross Compile Rust Program for Pi 2 (ARM) on Mac OS

## 0.1 Install toolchains
```
brew install arm-linux-gnueabihf-binutils

- list file in package
brew ls arm-linux-gnueabihf-binutils
brew ls --version arm-linux-gnueabihf-binutils

- list installed formula 
brew list --formula -l | grep arm
ls -l /usr/local/Cellar/ | grep arm

- list installed casks
brew list --casks
```
## Alternative, Download the prebuilt musl.cc cross toolchain
```
MUSLCC_DIR=~/musl-cc && mkdir -p ${MUSLCC_DIR} && MUSLCC_PREB_URL=$(curl -s mac.musl.cc | grep armv7l | grep cross) && curl ${MUSLCC_PREB_URL} | tar zxvvf - -C ${MUSLCC_DIR}
```

## 1. Install targets
```bash
rustup target list | grep arm

rustup target add armv7-unknown-linux-musleabihf
```

## 2. Edit `.cargo/config` file
```
[target.armv7-unknown-linux-musleabihf]
linker = "arm-linux-gnueabihf-ld"
```

## 3. Build
```
cargo build --target armv7-unknown-linux-musleabihf
```

## Reference
- https://pixelspark.nl/2020/cross-compiling-rust-programs-for-a-raspberry-pi-from-macos
- https://wiki.musl-libc.org/getting-started.html
- https://toml.io/en/
- https://doc.rust-lang.org/cargo/reference/config.html