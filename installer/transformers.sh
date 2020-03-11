#! /bin/sh -x
# Transformers installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-wheel
#   gcc-g++ git curl wget make cmake
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
pip3.7 install torch -f https://github.com/KoichiYasuoka/CygTorch
pip3.7 list |
( egrep '^sentencepiece ' ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/sentencepiece.sh | sh -x
)
pip3.7 list |
( egrep '^tokenizers ' ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/tokenizers.sh | sh -x
)
V=`pip3.7 list | sed -n 's/^tokenizers  *\([^ ]*\)  *$/\1/p'`
pip3.7 install transformers tokenizers==$V
exit 0
