这个例子是我自己写的一个demo
具体内容请看run.sh
里面记录了,我写程序过程中遇到的各种坑儿
我用的是cpu跑的
数据集是VCTK
kaldi job是3
kaldi放在了没有my-first-kaldi文件夹下
run.sh里面还用到了srilm,按照kaldi下的tools/install_srilm.sh安装即可


里面有三张jpg的图片,分别为:
    错误1:这张图片wer在90以上,包扩最后训练完也是在90以上,肯定存在问题,我最后重新做了lexcion等相关的文件,这个问题就解决了
    错误2:这个问题是一时疏忽造成的,很明显这个问题的wer为nan表示没有test集合,最后我看了一下test,发现里面的id字母大写了,没有对应上wav.scp文件
    正确:这个文件就是抛出来的正确结果,最后的wer在6%左右,具体数值我忘记了.
