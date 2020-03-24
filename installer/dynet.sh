#! /bin/sh -x
# DyNet installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-wheel
#   gcc-g++ git make cmake
case "`uname -a`" in
*' Cygwin') : ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/dynet$$
mkdir $D
cd $D
git clone --depth=1 https://github.com/clab/dynet
git clone --depth=1 https://gitlab.com/libeigen/eigen
EIGEN3_INCLUDE_DIR=$D/eigen
export EIGEN3_INCLUDE_DIR
F=eigen/unsupported/Eigen/CXX11/src/Tensor/TensorRandom.h
if fgrep -l __native_client__ $F
then ex -s $F << 'EOF'
%s/__native_client__/__CYGWIN__/
wq
EOF
fi
cd dynet
if fgrep -l cygdynet.dll setup.py
then :
else ( echo '/version="0.0.0"/a'
       sed -n 's/^__version__\( *=.*\)$/    version\1,/p' python/dynet.py.in
       cat << 'EOF'
.
%s/^DATA_FILES *= *\[\]/DATA_FILES=["..\/dynet\/cygdynet.dll"]/
%s/"install_data" *: *install_data *,//
/data_files.*os\.path\.join/s/"\.\." *, *"\.\."/"local","bin"/
wq
EOF
     ) | ex -s setup.py
fi
python3.7 setup.py bdist_wheel
cd build/py3.7-??bit/python/dist
pip3.7 install -U dyNET*.whl
rm -fr $D
exit 0
