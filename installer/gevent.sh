#! /bin/sh -x
# gevent installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-cffi
#   gcc-g++ git libuv-devel
case "`uname -a`" in
*' Cygwin') : ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/gevent$$
mkdir $D
cd $D
pip3.7 install greenlet
git clone --depth=1 https://github.com/gevent/gevent
cd gevent
env GEVENTSETUP_EMBED_LIBUV=False python3.7 setup.py bdist_wheel
cd dist
pip3.7 install gevent*.whl
rm -fr $D
exit 0
