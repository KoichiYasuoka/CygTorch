#! /bin/sh
# Tokenizers installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-wheel
#   gcc-g++ git wget
case "`uname -a`" in
*' Cygwin') : ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/tokenizers$$
mkdir $D
cd $D
PATH="$D/.cargo/bin:$PATH"
USERPROFILE="`cygpath -ad $D`"
export PATH USERPROFILE
wget https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-gnu/rustup-init.exe
chmod u+x rustup-init.exe
./rustup-init.exe << 'EOF'
y
2
x86_64-pc-windows-gnu
nightly
minimal
n
1

EOF
git clone --depth=1 https://github.com/huggingface/tokenizers
cd tokenizers/bindings/python
cargo build --release
( B=`cygpath -ad /usr/bin | sed 's/\\\\/\\\\\\\\\\\\\\\\/g'`
  for PYO in $D/.cargo/registry/src/*/pyo3-0.8.*
  do cd $PYO
     ( echo '/const *PYTHON_INTERPRETER/'
       echo 's/"python3"/"'$B'\\\\python3.7m.exe"/'
       cat << 'EOF'
s?^/*??
.+1,/^}/s?^?//?
/pythonXY/s/pythonXY:.*/pythonXY:python3.7m"/
.+1s?^?//?
EOF
       echo '%s/=native={}".*$/=native='$B'");/'
       echo wq
     ) | ex -s build.rs
     ex -s src/exceptions.rs << 'EOF'
%s/"windows"/"cygwin"/
wq
EOF
  done
)
rm -fr target/release/build/pyo3-*
cargo build --release
pip3.7 install git+https://github.com/KoichiYasuoka/setuptools-rust
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install tokenizers*.whl
rm -fr $D
exit 0
