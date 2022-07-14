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
V=${TOKENIZERS_VERSION-0.11.6}
PATH="$D/.cargo/bin:$PATH"
USERPROFILE="`cygpath -ad $D`"
PYO3_PYTHON="`cygpath -ad /usr/bin/python3.7`"
PYTHON_SYS_EXECUTABLE="$PYO3_PYTHON"
CC=$C-w64-mingw32-gcc.exe
CXX=$C-w64-mingw32-g++.exe
export PATH USERPROFILE PYO3_PYTHON PYTHON_SYS_EXECUTABLE CC CXX
curl -LO https://static.rust-lang.org/rustup/dist/"$C"-pc-windows-gnu/rustup-init.exe
chmod u+x rustup-init.exe
./rustup-init.exe -y --no-modify-path --default-host "$C"-pc-windows-gnu --default-toolchain 1.61.0 --profile minimal
curl -LO https://github.com/huggingface/tokenizers/archive/python-v$V.tar.gz
tar xzf python-v$V.tar.gz
find tokenizers-python-v$V -name rust-toolchain |
( while read F
  do echo 1.61.0 > $F
  done
)
cd tokenizers-python-v$V/bindings/python
( B=`cygpath -ad /usr/bin/cygpath | sed 's/\\\\/\\\\\\\\/g'`
  echo /fn from_file/a
  echo '        use std::process::Command;'
  echo '        let output = Command::new("'$B'").args(&["-ad",path]).output().expect("failed to execute cygpath");'
  echo '        let cygpath = String::from_utf8(output.stdout)?;'
  echo '        let path: &str = &cygpath.trim();'
  echo .
  echo wq
) | ex -s src/tokenizer.rs
( echo 1a
  echo ''
  echo import os
  echo 'os.environ["PATH"] += ":/usr/'$C'-w64-mingw32/sys-root/mingw/bin"'
  echo .
  echo wq
) | ex -s py_src/tokenizers/__init__.py
( echo /lexical-core/
  echo +
  echo 's/version = .*$/version = "0.7.6"/'
  echo +
  echo +
  echo 's/checksum = .*$/checksum = "6607c62aa161d23d17a9072cc5da0be67cdfc89d3afb1e8d9c842bebc2525ffe"/'
  echo wq
) | ex -s Cargo.lock
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
pip3.7 install 'setuptools-rust>=0.12.1' --no-build-isolation
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install tokenizers*.whl
rm -fr $D
exit 0
