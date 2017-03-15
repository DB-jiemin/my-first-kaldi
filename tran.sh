if [ ! -d tmp ];then
    mkdir tmp
fi
for filename in `ls $1 | grep wav`
do
	lame -V 2  --decode --resample 16 $1/$filename tmp/$filename
done
$(cp tmp/* $1)
$(rm tmp/*)
