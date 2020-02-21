#! /bin/sh -x
# PyTorch 1.4.0 installer for Cygwin64, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-wheel
#   gcc-g++ git make cmake
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo CygTorch is only for Cygwin64 >&2
   exit 2 ;;
esac
case "$1" in
--no-compile) exec pip3.7 install torch-1.4.0*.whl ;;
esac
PY_MAJOR_VERSION=3
PYTORCH_BUILD_VERSION=1.4.0+cpu
PYTORCH_BUILD_NUMBER=0
export PY_MAJOR_VERSION PYTORCH_BUILD_VERSION PYTORCH_BUILD_NUMBER
if [ ! -d pytorch1.4.0 ]
then git clone -b v1.4 --depth=1 https://github.com/pytorch/pytorch
     mv pytorch pytorch1.4.0
fi
cd pytorch1.4.0
P=`pwd`
if [ ! -d build ]
then pip3.7 install -r requirements.txt
     git submodule update --init --recursive
     if fgrep -l CYGWIN aten/src/ATen/CMakeLists.txt
     then :
     else ex -s aten/src/ATen/CMakeLists.txt << 'EOF'
%s/EMSCRIPTEN/CYGWIN/
wq
EOF
     fi
     mkdir build
     cd build 
     cmake .. `python3.7 ../scripts/get_python_cmake_flags.py` -DCYGWIN=ON -DBUILD_CAFFE2_OPS=OFF -DBUILD_PYTHON=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TEST=OFF -DCMAKE_BUILD_TYPE=Release -DINTERN_BUILD_MOBILE=OFF -DCMAKE_INSTALL_PREFIX=$P/torch -DCMAKE_PREFIX_PATH=/usr/lib/python3.7/site-packages -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-lpython3.7 -DNUMPY_INCLUDE_DIR=/usr/lib/python3.7/site-packages/numpy/core/include -DPYTHON_LIBRARY=/usr/lib/libpython3.7m.dll.a -DTORCH_BUILD_VERSION=1.4.0+cpu -DUSE_CUDA=OFF -DUSE_FBGEMM=OFF -DUSE_NUMPY=ON -DNDEBUG=ON
     cd ..
fi
awk '
BEGIN{
  printf("%%s/^\\(install_requires *= *\\[\\) *\\].*$/\\1");
}
{
  printf("%c%s%c,",34,$0,34);
}
END{
  printf("]/\nwq\n");
}' requirements.txt | ex -s setup.py
fgrep -l _WIN32 c10/util/*.cpp c10/util/*.h torch/csrc/DataLoader.cpp test/cpp/jit/torch_python_test.cpp |
( while read F
  do ex -s $F << 'EOF'
%s/_WIN32/__CYGWIN__/
wq
EOF
  done
)
fgrep -l __ANDROID__ torch/csrc/jit/script/*.cpp |
( while read F
  do ex -s $F << 'EOF'
%s/__ANDROID__/__CYGWIN__/
wq
EOF
  done
)
fgrep -l '(_MSC_VER)' aten/src/ATen/cpu/vec256/vec256*.h |
( while read F
  do ex -s $F << 'EOF'
%s/(_MSC_VER)/(__CYGWIN__)/
wq
EOF
  done
)
F=aten/src/ATen/native/DispatchStub.cpp
if fgrep -l '__x86_64' $F
then :
else ex -s $F << 'EOF'
/<cpuinfo\.h>/i
#undef __x86_64__
#undef __x86_64
.
wq
EOF
fi
F=torch/csrc/jit/script/python_tree_views.cpp
if egrep -l '^#undef _C' $F
then :
else ex -s $F << 'EOF'
/ _C/i
#undef _C
.
wq
EOF
fi
cd build
set `sed -n 's/^cpu cores.*://p' /proc/cpuinfo` 1
M=`expr $1 + 1`
make --jobs=$M shm || exit 1
L=caffe2/torch/CMakeFiles/torch_python.dir/link.txt
if egrep -l -e ' -lpython3\.7$' $L
then :
elif [ -s $L ]
then ( echo '1s?[^ ]*lib/libshm.dll.a?-L'$P'/build/lib?'
       echo '1s/$/ -lshm -lpython3.7/'
       echo wq
     ) | ex -s $L
fi
L=caffe2/CMakeFiles/caffe2_pybind11_state.dir/link.txt
if egrep -l -e ' -lpython3\.7$' $L
then :
elif [ -s $L ]
then ( echo '1s/$/ -lpython3.7/'
       echo wq
     ) | ex -s $L
fi
make --jobs=$M torch_python || exit 1
cd ..
python3.7 setup.py develop
if fgrep -l data_files setup.py
then :
else ex -s setup.py << 'EOF'
/packages=packages,/a
        data_files=[("bin",glob.glob("build/bin/*"))],
.
wq
EOF
fi
python3.7 setup.py bdist_wheel
cd dist
exec pip3.7 install torch-1.4.0*.whl
