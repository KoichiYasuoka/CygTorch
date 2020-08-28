#! /bin/sh
# Pytextspan installer for Cygwin, which requires:
#   python37-devel python37-pip python37-wheel
#   gcc-g++ git wget
case "`uname -a`" in
*'x86_64 Cygwin') C=x86_64 ;;
*'i686 Cygwin') C=i686 ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/pytextspan$$
mkdir $D
cd $D
PATH="$D/.cargo/bin:$PATH"
USERPROFILE="`cygpath -ad $D`"
PYTHON_SYS_EXECUTABLE="`cygpath -ad /usr/bin/python3.7`"
export PATH USERPROFILE PYTHON_SYS_EXECUTABLE
wget https://static.rust-lang.org/rustup/dist/"$C"-pc-windows-gnu/rustup-init.exe
chmod u+x rustup-init.exe
./rustup-init.exe -y --no-modify-path --default-host "$C"-pc-windows-gnu --default-toolchain nightly --profile minimal
wget https://github.com/tamuhey/textspan/archive/python/0.3.1.tar.gz
tar xzf 0.3.1.tar.gz
cd textspan-python*/python
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
wq
EOF
  done
)
rm -fr target/release/build/pyo3-*
cargo build --release
cp target/release/textspan.dll textspan/textspan.dll
chmod 755 textspan/textspan.dll
pip3.7 install poetry
pip3.7 install . --no-build-isolation
rm -fr $D
exit 0
