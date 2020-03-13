#! /bin/sh
# Pytokenizations installer for Cygwin, which requires:
#   python37-devel python37-pip python37-wheel
#   gcc-g++ git wget
case "`uname -a`" in
*'x86_64 Cygwin') C=x86_64 ;;
*'i686 Cygwin') C=i686 ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/pytokenizations$$
mkdir $D
cd $D
PATH="$D/.cargo/bin:$PATH"
USERPROFILE="`cygpath -ad $D`"
export PATH USERPROFILE
wget https://static.rust-lang.org/rustup/dist/"$C"-pc-windows-gnu/rustup-init.exe
chmod u+x rustup-init.exe
( echo y
  echo 2
  echo "$C"-pc-windows-gnu
  echo nightly
  echo minimal
  echo n
  echo 1
  echo ''
) | ./rustup-init.exe
git clone --depth=1 https://github.com/tamuhey/tokenizations
cd tokenizations/python
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
%s/"windows"/"dummy"/
wq
EOF
  done
)
rm -fr target/release/build/pyo3-*
cargo build --release
cp target/release/tokenizations.dll tokenizations/tokenizations.dll
chmod 755 tokenizations/tokenizations.dll
pip3.7 install .
rm -fr $D
exit 0
