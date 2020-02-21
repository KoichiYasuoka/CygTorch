# CygTorch

[PyTorch](https://github.com/pytorch/pytorch) 1.4.0 installer for [Cygwin64](https://www.cygwin.com/).

## Usage

See [PyTorch page](https://pytorch.org). CPU only.

## Installation

Only for Cygwin64 with `python37-devel` `python37-pip` `python37-cython` `python37-numpy` `python37-wheel` `gcc-g++` and `git`:

```sh
cd /tmp
git clone --depth=1 https://github.com/KoichiYasuoka/CygTorch
cd CygTorch
sh -x ./install.sh --no-compile
```

