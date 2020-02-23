#! /bin/sh
# h5py installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-cffi
#   gcc-g++ git
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
pip3.7 install greenlet
git clone --depth=1 https://github.com/gevent/gevent
cd gevent
ex -s src/gevent/libuv/_corecffi_build.py << 'EOF'
/^LIBUV_EMBED *=/a
LIBUV_EMBED=False
.
wq
EOF
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install gevent*.whl
exit 0
