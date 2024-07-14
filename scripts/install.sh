#!/usr/bin/env bash
set -eEuo pipefail

TB_PATH=$PWD/tigerbeetle
ZIG_PATH=$TB_PATH/zig

echo "Installing TigerBeetle..."
git clone --recursive https://github.com/tigerbeetle/tigerbeetle.git
(cd $TB_PATH && ./scripts/install_zig.sh)

echo "Building TigerBeetle Dotnet..."
(cd $TB_PATH/src/clients/dotnet && $ZIG_PATH/zig build clients:dotnet -Drelease -Dconfig=production)

echo "Building TigerBeetle Java..."
(cd $TB_PATH/src/clients/java && $ZIG_PATH/zig build clients:java -Drelease -Dconfig=production)

echo "Building TigerBeetle Go..."
(cd $TB_PATH/src/clients/go && $ZIG_PATH/zig build clients:go -Drelease -Dconfig=production)