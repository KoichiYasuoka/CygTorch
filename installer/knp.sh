#! /bin/sh -x
# JUMAN and KNP installer for Cygwin, which requires:
#   gcc-g++ wget make zlib-devel
case "`uname`" in
CYGWIN*) CYGWIN=true ;;
*) CYGWIN=false ;;
esac
if [ ! -s /usr/include/zlib.h ]
then echo zlib.h not found. Please install zlib-devel or zlib1g-dev >&2
     exit 2
fi
D=/tmp/knp$$
mkdir $D
if [ ! -x /usr/local/bin/juman ]
then if [ -x /usr/bin/juman -a -d /usr/lib/juman -a -s /usr/include/juman.h ]
     then if [ ! -d /usr/local/share/juman ]
          then if $CYGWIN
	       then mkdir -p /usr/local/share
		    ln -s /usr/lib/juman /usr/local/share
	       else sudo mkdir -p /usr/local/share
		    sudo ln -s /usr/lib/juman /usr/local/share
               fi
          fi
     else cd $D
	  wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2
	  tar xjf juman-7.01.tar.bz2
	  cd juman-7.01
	  ./configure
	  make || exit 1
	  if $CYGWIN
	  then make install
	  else sudo make install
	  fi
     fi
fi
if [ ! -x /usr/local/bin/knp ]
then cd $D
     wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.19.tar.bz2
     tar xjf knp-4.19.tar.bz2
     cd knp-4.19/CRF++-0.58
     if egrep '^#ifndef __CYGWIN__' winmain.h
     then :
     else ex -s winmain.h << 'EOF'
/#define  *main/i
#ifndef __CYGWIN__
.
/#endif/i
#endif
.
wq
EOF
     fi
     cd ../dict/ebcf
     if [ ! -s noun.idx ]
     then for F in noun.idx.xz noun.dat.xz.1 noun.dat.xz.2
          do wget https://github.com/KoichiYasuoka/knp-cygwin64/raw/master/share/knp/dict/ebcf/$F
          done
          cat noun.dat.xz.[12] > noun.dat.xz
          touch noun.idx.xz
          unxz noun.idx.xz noun.dat.xz
     fi
     if [ ! -s cf.idx ]
     then for F in cf.idx.xz cf.dat.xz.1 cf.dat.xz.2
          do wget https://github.com/KoichiYasuoka/knp-cygwin64/raw/master/share/knp/dict/ebcf/$F
          done
          cat cf.dat.xz.[12] > cf.dat.xz
          touch cf.idx.xz
          unxz cf.idx.xz cf.dat.xz
     fi
     cd ../..
     ./configure
     make || exit 1
     if $CYGWIN
     then make install
     else sudo make install
     fi
fi
rm -fr $D
exit 0
