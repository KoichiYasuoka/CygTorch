#! /bin/sh -x
# NLP-Cube installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy
#   gcc-g++ gcc-fortran git curl make cmake libopenblas liblapack-devel
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
pip3.7 install -U cython wheel pybind11
pip3.7 install scipy@git+https://github.com/scipy/scipy
pip3.7 list |
( egrep '^dyNET ' ||
  curl https://raw.githubusercontent.com/KoichiYasuoka/CygTorch/master/installer/dynet.sh | sh -x
)
pip3.7 install nlpcube
exit 0
