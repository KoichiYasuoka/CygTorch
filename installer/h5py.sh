#! /bin/sh -x
# h5py installer for Cygwin, which requires:
#   python37-devel python37-pip python37-cython python37-numpy python37-wheel
#   gcc-g++ git libhdf5-devel
case "`uname -a`" in
*' Cygwin') : ;;
*) echo Only for Cygwin >&2
   exit 2 ;;
esac
D=/tmp/h5py$$
mkdir $D
cd $D
git clone --depth=1 https://github.com/h5py/h5py
cd h5py
set `sed -n 's/^#define *H5_VERSION *//p' /usr/include/H5pubconf.h | tr -d '"'` 1.10.2
python3.7 setup.py configure --hdf5-version=$1
python3.7 setup.py configure --hdf5=/usr/lib/libhd5.dll.a
python3.7 setup.py bdist_wheel
cd dist
pip3.7 install h5py*.whl
rm -fr $D
exit 0
