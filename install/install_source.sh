#!/bin/bash
# NOTE: this is run as root

# load configuration
RUNDIR=$(dirname $0)
source $RUNDIR/install.cfg

pushd $REDDIT_SRC

# bison
# need 3.1+ rather than packaged 3.0.4
if [ ! -d bison ]; then
    sudo -u $REDDIT_USER git clone https://github.com/akimd/bison.git
fi
pushd bison
sudo -u $REDDIT_USER git checkout v3.4.1
sudo -u $REDDIT_USER git submodule update --init
sudo -u $REDDIT_USER ./bootstrap
sudo -u $REDDIT_USER ./configure
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd

# folly
# why -fPIC flag: https://stackoverflow.com/questions/13812185/how-to-recompile-with-fpic/13812368#13812368
if [ ! -d folly ]; then
    sudo -u $REDDIT_USER git clone https://github.com/facebook/folly.git
fi
pushd folly
sudo -u $REDDIT_USER git checkout 60be5ec6d5b85c89cadd6ff9a986fa59e88b714d
sudo -u $REDDIT_USER mkdir -p _build
pushd _build
sudo -u $REDDIT_USER cmake -DCMAKE_CXX_FLAGS=-fPIC ..
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd
popd

# rsocket, yarpl
# depends on folly
# last tag is from 2017, so just picked a random recent commit
if [ ! -d rsocket-cpp ]; then
    sudo -u $REDDIT_USER git clone https://github.com/rsocket/rsocket-cpp.git
fi
pushd rsocket-cpp
sudo -u $REDDIT_USER git checkout 7c72d18f04960c3a51985603a69268a252b9a800
sudo -u $REDDIT_USER mkdir -p _build
pushd _build
sudo -u $REDDIT_USER cmake -DBUILD_TESTS=OFF ../
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd
popd

# fmt
# had problems with version 6.0.0
if [ ! -d fmt ]; then
    sudo -u $REDDIT_USER git clone https://github.com/fmtlib/fmt
fi
pushd fmt
sudo -u $REDDIT_USER git checkout 5.3.0
sudo -u $REDDIT_USER mkdir -p build
pushd build
sudo -u $REDDIT_USER cmake ..
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd
popd

# fizz
# WARNING: choosing wrong version will make wangle build fail
# using the same tag/version as fbthrift, fallback to version
# from wangle's release date, a little older
if [ ! -d fizz ]; then
    sudo -u $REDDIT_USER git clone https://github.com/facebookincubator/fizz.git
fi
pushd fizz
sudo -u $REDDIT_USER git checkout v2019.07.29.00
sudo -u $REDDIT_USER mkdir -p _build
pushd _build
sudo -u $REDDIT_USER cmake ../fizz
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd
popd

# wangle
if [ ! -d wangle ]; then
    sudo -u $REDDIT_USER git clone https://github.com/facebook/wangle.git
fi
pushd wangle
sudo -u $REDDIT_USER git checkout 7614031c1d10a1ef61e523c1ea6c6dc4f7f48ee8
sudo -u $REDDIT_USER mkdir _build
pushd _build
sudo -u $REDDIT_USER cmake ../wangle
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd
popd

# fbthrift
# get compatible folly and wangle commit ids from:
#   build/deps/github_hashes/facebook/folly-rev.txt
#   build/deps/github_hashes/facebook/wangle-rev.txt
if [ ! -d fbthrift ]; then
    sudo -u $REDDIT_USER git clone https://github.com/facebook/fbthrift
fi
pushd fbthrift
sudo -u $REDDIT_USER git checkout v2019.07.29.00
sudo -u $REDDIT_USER mkdir -p _build
pushd _build
sudo -u $REDDIT_USER cmake -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_CXX_STANDARD=17 ..
sudo -u $REDDIT_USER make -j $(nproc)
make install
popd
popd

# python-thrift
# WARNING: some syntax errors are shown on the 'setup.py install' step, 
# for TAsyncioServer.py, asyncio.py, and inspect.py.
pushd fbthrift/thrift/lib/py

# WARNING: nasty hack, bump the python thrift module version 
# up from 0.1 to 0.9.3 for pycassa compatibility.
# python-pycassa installs python-thrift
# and easy install pycassa installs thrift
# 0.9.3. Apparently facebook 
# never bumped the python-thrift version up from 0.1.
# Alternatives: try building pycassa from source after
# fbthrift's python-thrift is built and installed.
sudo -u $REDDIT_USER sed -i "s/version = '0.1',/version = '0.9.3',/g" setup.py

sudo -u $REDDIT_USER python setup.py build
python setup.py install
popd

# baseplate
# verify halfway working with: $ baseplate-healthcheck
if [ ! -d baseplate.py ]; then
    sudo -u $REDDIT_USER git clone https://github.com/reddit/baseplate.py.git
fi
pushd baseplate.py
sudo -u $REDDIT_USER git checkout v0.28.7
sudo -u $REDDIT_USER python setup.py build
python setup.py install

# pycaptcha
# resolve "ImportError: No module named Image" in
# PyCAPTCHA-0.4-py2.7.egg
if [ ! -d PyCAPTCHA ]; then
    sudo -u $REDDIT_USER git clone https://github.com/yinpeng/PyCAPTCHA
fi
pushd PyCAPTCHA
sudo -u $REDDIT_USER python setup.py build
python setup.py install
popd

# done, pop pushd $REDDIT_SRC
popd