#! /bin/sh
# Allennlp installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-cffi
#   gcc-g++ gcc-fortran git curl make cmake
#   libopenblas liblapack-devel libhdf5-devel libfreetype-devel
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
D=/tmp/allennlp-install$$
mkdir $D
pip3.7 install -U cython wheel pybind11 greenlet mecab-cygwin
pip3.7 install 'spacy>=2.2.2' --no-build-isolation
pip3.7 install torch -f https://github.com/KoichiYasuoka/CygTorch
pip3.7 install scipy@git+https://github.com/scipy/scipy
pip3.7 list |
( if egrep '^sentencepiece '
  then :
  else cd $D
       curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/sentencepiece.sh | sh -x
  fi
)
pip3.7 list |
( if egrep '^h5py '
  then :
  else cd $D
       curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/h5py.sh | sh -x
  fi
)
pip3.7 install allennlp 'spacy>=2.2.2'
rm -fr $D
exit 0
