#!/bin/bash
./path.sh

#utils/utt2spk_to_spk2utt.pl audio/test/utt2spk > audio/test/spk2utt
#utils/utt2spk_to_spk2utt.pl audio/train/utt2spk > audio/train/spk2utt
#
#steps/make_mfcc.sh --nj 3 --cmd run.pl audio/test exp/make_mfcc/test mfcc
#steps/make_mfcc.sh --nj 3 --cmd run.pl audio/train exp/make_mfcc/train mfcc

#for i in train test;do
#    utils/utt2spk_to_spk2utt.pl audio/$i/utt2spk > audio/$i/spk2utt
#    steps/make_mfcc.sh --nj 3 --cmd run.pl audio/$i exp/make_mfcc/$i mfcc
#    #steps/compute_cmvn_stats.sh audio/train exp/make_mfcc/train mfcc
#    steps/compute_cmvn_stats.sh audio/$i exp/make_mfcc/$i mfcc
#done

sh utils/prepare_lang.sh data/dict "SIL" data/local/lang data/lang

#ngram-count -order 1 -write-vocab data/local/tmp/vocal-full.txt -wbdiscount -text data/local/corpus.txt data/local/lm.arpa 
gawk -F"	" '{print $1;}' data/dict/lexicon.txt > aaa
./kaldi-master/tools/srilm/lm/bin/i686-m64/ngram-count -order 3 -text data/local/corpus.txt -lm source.arpa -vocab aaa
rm aaa
# -order  指定n-gram的n是多少,默认是3
# -text   提供输入的语料文件,统计该语料中的n-gram
# -lm     指定输出的lm文件
# -vocab  用来指定对哪些词进行n-gram统计
# note:参数顺序无所谓

#cat source.arpa |./kaldi-master/src/lmbin/arpa2fst - - | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstprint | utils/eps2disambig.pl | utils/s2eps.pl | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstrmepsilon | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstarcsort --sort_type=ilabel > data/lang/G.fst

#./kaldi-master/src/lmbin/arpa2fst source.arpa |\
#    ./kaldi-master/tools/openfst-1.3.4/src/bin/fstprint | \
#    utils/eps2disambig.pl |\
#    utils/s2eps.pl | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false |\
#    ./kaldi-master/tools/openfst-1.3.4/src/bin/fstrmepsilon | \
#    ./kaldi-master/tools/openfst-1.3.4/src/bin/fstarcsort --sort_type=ilabel > data/lang/G.fst
./kaldi-master/src/lmbin/arpa2fst source.arpa | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstprint | utils/eps2disambig.pl | utils/s2eps.pl | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstrmepsilon | ./kaldi-master/tools/openfst-1.3.4/src/bin/fstarcsort --sort_type=ilabel > data/lang/G.fst

steps/train_mono.sh --nj 3 --cmd run.pl audio/train data/lang exp/mono

utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
#--config conf/decode.config

steps/decode.sh --nj 3 --cmd run.pl --config conf/decode.config exp/mono/graph audio/test exp/mono/decode


sh steps/align_si.sh --boost-silence 1.25 --nj 3 --cmd run.pl audio/train data/lang exp/mono exp/mono_ali || exit 1

sh steps/train_deltas.sh --cmd run.pl 2000 22000 audio/train data/lang exp/mono_ali exp/tri1 || exit 1

sh utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
sh steps/decode.sh --config conf/decode.config --nj 3 --cmd run.pl exp/tri1/graph audio/test exp/tri1/decode 

sh steps/align_si.sh --boost-silence 1.25 --nj 3 --cmd run.pl audio/train data/lang exp/tri1 exp/deltas_ali || exit 1

sh steps/train_lda_mllt.sh --cmd run.pl --splice-opts "--left-context=3 --right-context=3" \
    2500 30000 audio/train data/lang exp/deltas_ali exp/tri2b

sh utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
sh steps/decode.sh --config conf/decode.config --nj 3 --cmd run.pl exp/tri1/graph audio/test exp/tri1/decode 

echo
echo "===== run.sh script finished ====="
echo
