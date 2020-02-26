#! /bin/sh -x
# StanfordNLP installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy gcc-g++
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
pip3.7 install torch -f https://github.com/KoichiYasuoka/CygTorch
pip3.7 install stanfordnlp
exit 0
