#! /bin/sh -x
# Camphr[Juman] installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-cffi
#   gcc-g++ mingw64-x86_64-gcc-g++ gcc-fortran git curl make cmake
#   libopenblas liblapack-devel libhdf5-devel libfreetype-devel libuv-devel
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
if [ ! -x /usr/local/bin/knp ]
then pip3.7 install knp-cygwin64@git+https://github.com/KoichiYasuoka/knp-cygwin64
fi
pip3.7 list |
( egrep '^allennlp +'$ALLENNLP_VERSION ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/allennlp.sh | sh -x
)
pip3.7 list |
( egrep '^tokenizers +'$TOKENIZERS_VERSION ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/tokenizers.sh | sh -x
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
V=`pip3.7 list | sed -n 's/^tokenizers  *\([^ ]*\) *$/\1/p'`
pip3.7 install -U tokenizers==$V 'camphr[juman]>=0.7'
exit 0
