#!/bin/bash

set -e

tar zxf cuwal-${CUWA_VERSION}.tar.gz
cd cuwal-${CUWA_VERSION}

autoconf

if [[ -f ../conf.patch-${CUWA_VERSION} ]]; then
    patch configure -f -i ../conf.patch-${CUWA_VERSION} -l -o configure.my.cuwa-build
    chmod +x configure.my.cuwa-build
else
    ln -s configure configure.my.cuwa-build
fi

./configure.my.cuwa-build
make
cd apache
make install

    
