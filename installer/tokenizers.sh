#! /bin/sh
# Tokenizers installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-wheel
#   mingw64-*-gcc-g++ git curl
case "`uname -a`" in
*'x86_64 Cygwin') C=x86_64 ;;
*'i686 Cygwin') C=i686 ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/tokenizers$$
mkdir $D
cd $D
PATH="$D/.cargo/bin:$PATH"
USERPROFILE="`cygpath -ad $D`"
PYO3_PYTHON="`cygpath -ad /usr/bin/python3.7`"
PYTHON_SYS_EXECUTABLE="$PYO3_PYTHON"
CXX=$C-w64-mingw32-g++.exe
export PATH USERPROFILE PYO3_PYTHON PYTHON_SYS_EXECUTABLE CXX
curl -LO https://static.rust-lang.org/rustup/dist/"$C"-pc-windows-gnu/rustup-init.exe
chmod u+x rustup-init.exe
./rustup-init.exe -y --no-modify-path --default-host "$C"-pc-windows-gnu --default-toolchain stable --profile minimal
curl -LO https://github.com/huggingface/tokenizers/archive/python-v0.9.4.tar.gz
tar xzf python-v0.9.4.tar.gz
cd tokenizers-python-v0.9.4/bindings/python
cargo build --release
( B=`cygpath -ad /usr/bin | sed 's/\\\\/\\\\\\\\\\\\\\\\/g'`
  for PYO in $D/.cargo/registry/src/*/pyo3-0*
  do cd $PYO
     ( echo '%s/"python{}{}"/"python{}.{}m"/'
       echo '%s/=native={}".*$/=native='$B'");/'
       echo wq
     ) | ex -s build.rs
     ex -s src/exceptions.rs << 'EOF'
%s/"windows"/"dummy"/
%s/(all(windows/(all(dummy/
wq
EOF
  done
  cd $D/.cargo/registry/src/*/parking_lot-*
  ex -s src/lib.rs << 'EOF'
%s/feature(asm)/feature(llvm_asm)/
wq
EOF
  ex -s src/elision.rs << 'EOF'
%s/ asm!/ llvm_asm!/
wq
EOF
  cd $D/.cargo/registry/src/*/onig_sys-*
  ex -s build.rs << 'EOF'
/let mut cc/a
    cc.define("ONIG_NO_PRINT", Some("1"));
.
wq
EOF
  for F in oniguruma/src/config.h.win*
  do ex -s $F << 'EOF'
/^#define uid_t/d
/^#define gid_t/d
wq
EOF
  done
)
rm -fr target/release/build/pyo3-* target/release/build/parking_lot-* target/release/build/onig_sys-*
cargo build --release
curl -LO https://github.com/PyO3/setuptools-rust/archive/v0.11.1.tar.gz
tar xzf v0.11.1.tar.gz
( cd setuptools-rust-*
  ex setuptools_rust/build.py << 'EOF'
%s/"PYTHON_SYS_EXECUTABLE"/# &/
%s/"PYO3_PYTHON"/# &/
wq
EOF
  pip3.7 install .
)
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install tokenizers*.whl
rm -fr $D
exit 0
