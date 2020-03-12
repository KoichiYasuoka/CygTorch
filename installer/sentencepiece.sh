#! /bin/sh -x
# SentencePiece installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-wheel
#   gcc-g++ git make cmake
case "`uname -a`" in
*' Cygwin') : ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/sentencepiece$$
mkdir $D
cd $D
git clone --depth=1 https://github.com/google/sentencepiece
cd sentencepiece
cmake . && make
cd python
( echo /version=version,/a
  echo '    data_files=[("local/bin",['
  ls ../src/*.dll | sed 's/^.*$/"&",/'
  echo '])],'
  echo .
  echo wq
) | ex -s setup.py
env PKG_CONFIG_PATH=.. CPATH=../src LIBRARY_PATH=../src python3.7 setup.py bdist_wheel
cd dist
pip3.7 install sentencepiece*.whl
rm -fr $D
exit 0
