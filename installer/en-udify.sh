#! /bin/sh -x
# en-udify installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-cffi
#   gcc-g++ mingw64-x86_64-gcc-g++ gcc-fortran git curl make cmake
#   libopenblas liblapack-devel libhdf5-devel libfreetype-devel libuv-devel
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
ALLENNLP_VERSION=1.3.0
TOKENIZERS_VERSION=0.9.4
TRANSFORMERS_VERSION=3.5.1
export ALLENNLP_VERSION TOKENIZERS_VERSION TRANSFORMERS_VERSION
pip3.7 list |
( egrep '^allennlp +'$ALLENNLP_VERSION ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/allennlp.sh | sh -x
)
if [ -x /usr/lib/python3.7/site-packages/tokenizations/tokenizations*.dll ]
then :
else pip3.7 uninstall pytokenizations
     curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/pytokenizations.sh | sh -x
fi
if [ -x /usr/lib/python3.7/site-packages/textspan/textspan*.dll ]
then :
else pip3.7 uninstall pytextspan
     curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/pytextspan.sh | sh -x
fi
pip3.7 list |
( if egrep '^en-udify +0.7'
  then :
  else pip3.7 install tokenizers==$TOKENIZERS_VERSION transformers==$TRANSFORMERS_VERSION https://github.com/PKSHATechnology-Research/camphr_models/releases/download/0.7.0/en_udify-0.7.tar.gz 'camphr>=0.7.2' 'unofficial-udify>=0.3.0' 'sentencepiece>=0.1.94'
  fi
)
python3.7 -c '
import spacy
nlp=spacy.load("en_udify")
quit()
'
exit 0
