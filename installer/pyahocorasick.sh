#! /bin/sh -x
# Pyhocorasick installer for Cygwin, which requires:
#   python37-devel python37-pip python37-wheel
#   gcc-g++ git
case "`uname -a`" in
*' Cygwin') : ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/pyhocorasick$$
mkdir $D
cd $D
git clone --depth=1 https://github.com/WojciechMula/pyahocorasick
cd pyahocorasick
if fgrep -l '&PyType_Type' posix.h
then ex -s posix.h << 'EOF'
%s/&PyType_Type/NULL/
wq
EOF
fi
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install pyahocorasick*.whl
rm -fr $D
exit 0
