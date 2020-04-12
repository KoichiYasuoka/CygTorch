#! /bin/sh -x
# Juman and KNP installer for Cygwin, which requires:
#   gcc-g++ wget make
case "`uname -a`" in
*'x86_64 Cygwin') : ;;
*) echo Only for Cygwin64 >&2
   exit 2 ;;
esac
D=/tmp/knp$$
mkdir $D
if [ ! -x /usr/local/bin/juman.exe ]
then cd $D
     wget 'http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2' -O juman.tar.gz
     tar jxf juman.tar.gz
     cd juman-7.01
     ./configure
     make && make install
fi
if [ ! -x /usr/local/bin/knp ]
then if [ ! -x /cygdrive/?/Program?Files/knp/knp.exe ]
     then cd $D
	  wget 'http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.11-x64-installer.exe' -O knp-installer.exe
	  chmod u+x knp-installer.exe
	  ./knp-installer.exe
     fi
     cat > /usr/local/bin/knp << 'EOF'
#! /bin/sh
iconv -f utf-8 -t cp932 | exec /cygdrive/?/Program?Files/knp/knp.exe "$@" | iconv -f cp932 -t utf-8
EOF
     chmod 755 /usr/local/bin/knp
fi
rm -fr $D
exit 0
