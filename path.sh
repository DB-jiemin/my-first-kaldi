export KALDI_ROOT=`pwd`/kaldi-master
export PATH=$PWD/utils/:$KALDI_ROOT/src/bin:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/src/fstbin/:$KALDI_ROOT/src/gmmbin/:$KALDI_ROOT/src/featbin/:$KALDI_ROOT/src/lm/:$KALDI_ROOT/src/sgmmbin/:$KALDI_ROOT/src/sgmm2bin/:$KALDI_ROOT/src/fgmmbin/:$KALDI_ROOT/src/latbin/:$PWD:$PATH:$KALDI_ROOT/tools/srilm/bin/i686-m64 #:$KALDI_ROOT/kaldi-master/tools/openfst-1.3.4/src/bin
export LD_LIBRARY_PATH=$KALDI_ROOT/kaldi-master/tools/openfst-1.3.4/lib:$LD_LIBRARY_PATH
export LC_ALL=C
