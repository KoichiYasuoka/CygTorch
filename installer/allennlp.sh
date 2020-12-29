#! /bin/sh -x
# AllenNLP installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-cffi
#   gcc-g++ mingw64-x86_64-gcc-g++ gcc-fortran git curl make cmake
#   libopenblas liblapack-devel libhdf5-devel libfreetype-devel libuv-devel
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
pip3.7 install -U cython wheel pybind11 mecab-cygwin
pip3.7 install 'spacy>=2.2.2' scipy --no-build-isolation
pip3.7 install torch -f https://github.com/KoichiYasuoka/CygTorch
pip3.7 list |
( egrep '^h5py ' ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/h5py.sh | sh -x
)
pip3.7 list |
( egrep '^gevent ' ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/gevent.sh | sh -x
)
pip3.7 list |
( egrep '^tokenizers +'$TOKENIZERS_VERSION ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/tokenizers.sh | sh -x
)
V=`pip3.7 list | sed -n 's/^tokenizers  *\([^ ]*\) *$/tokenizers==\1/p'`
case "$ALLENNLP_VERSION" in
'') A=allennlp ;;
*) A=allennlp==$ALLENNLP_VERSION ;;
esac
case "$TRANSFORMERS_VERSION" in
'') T='' ;;
*) T="transformers==$TRANSFORMERS_VERSION" ;;
esac
pip3.7 install $V $A $T 'spacy>=2.2.2' 'sentencepiece>=0.1.94'
exit 0
