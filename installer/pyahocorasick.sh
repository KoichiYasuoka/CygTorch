#! /bin/sh -x
# pyhocorasick installer for Cygwin
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
