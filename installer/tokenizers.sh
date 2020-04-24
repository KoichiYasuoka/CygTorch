#! /bin/sh
# Tokenizers installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-wheel
#   gcc-g++ git wget
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
PYTHONIOENCODING=utf-8
export PATH USERPROFILE PYTHONIOENCODING
wget https://static.rust-lang.org/rustup/dist/"$C"-pc-windows-gnu/rustup-init.exe
chmod u+x rustup-init.exe
./rustup-init.exe -y --no-modify-path --default-host "$C"-pc-windows-gnu --default-toolchain nightly --profile minimal
wget https://github.com/huggingface/tokenizers/archive/python-v0.7.0.tar.gz
tar xzf python-v0.7.0.tar.gz
cd tokenizers-python-v0.7.0/bindings/python
cargo build --release
( B=`cygpath -ad /usr/bin | sed 's/\\\\/\\\\\\\\\\\\\\\\/g'`
  for PYO in $D/.cargo/registry/src/*/pyo3-0*
  do cd $PYO
     ( echo '/const *PYTHON_INTERPRETER/'
       echo 's/"python3"/"'$B'\\\\python3.7m.exe"/'
       cat << 'EOF'
s?^/*??
.+1,/^}/s?^?//?
/pythonXY/s/pythonXY:.*/pythonXY:python3.7m"/
.+1s?^?//?
/=native={}\\\\libs"/s/=native={}.*$/=native={}"/
.+1,/);/s?^?//?
EOF
       echo '%s/=native={}".*$/=native='$B'");/'
       echo wq
     ) | ex -s build.rs
     ex -s src/exceptions.rs << 'EOF'
%s/"windows"/"dummy"/
wq
EOF
  done
)
rm -fr target/release/build/pyo3-*
cargo build --release
pip3.7 install git+https://github.com/PyO3/setuptools-rust
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install tokenizers*.whl
rm -fr $D
exit 0
