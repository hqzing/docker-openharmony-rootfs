#!/bin/sh
set -e

wget https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.9.tar.gz
tar -zxf openssl-3.0.9.tar.gz
cd openssl-openssl-3.0.9/
./Configure --prefix=/opt/openssl-musl
make -j$(nproc)
make install
cd ..

wget https://curl.se/download/curl-8.8.0.tar.gz
tar -zxf curl-8.8.0.tar.gz
cd curl-8.8.0/
# Static linking with libcurl but dynamic linking with other libraries (openssl and libc).
./configure \
    --with-openssl=/opt/openssl-musl \
    --prefix=/opt/curl-musl \
    --enable-static \
    --disable-shared \
    --with-ca-bundle=/etc/ssl/certs/cacert.pem \
    --with-ca-path=/etc/ssl/certs
make -j$(nproc)
make install
cd ..

rm -rf ./openssl* ./curl*
