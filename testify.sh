#!/bin/bash

if [ -z "$1" ]
	then
		echo "Usage: ./"$( basename "$0" )" the lex file."
		exit
fi

echo
echo  "t*.res1 - \n line endings"
echo  "t*.res2 - \r line endings"
echo  "t*.res3 - \r\n line endings"
echo

mkdir -p ./tmp
flex -o ./tmp/flex.c $1
gcc -ll ./tmp/flex.c -o ./tmp/a.out > /dev/null

for f in ./t*.in; do
	t=${f%%.in}
	./tmp/a.out < $f > $t.res1
	cat $f | perl -p -e 's/\n/\r/g' | ./tmp/a.out > $t.res2
	cat $f | perl -p -e 's/\n/\r\n/g' | ./tmp/a.out > $t.res3
	DIFF1=$(diff $t.res1 $t.out)
	DIFF2=$(diff $t.res2 $t.out)
	DIFF3=$(diff $t.res3 $t.out)

	if [ "$DIFF1" == "" ] && [ "$DIFF2" == "" ] && [ "$DIFF3" == "" ]; then
		echo "Test $f OK!"
	else
		printf "Test $f failed with line ending(s): "
		if [ "$DIFF1" != "" ]; then
			printf "LF, "
		fi
		if [ "$DIFF2" != "" ]; then
			printf "CR, "
		fi
		if [ "$DIFF3" != "" ]; then
			printf "CRLF"
		fi
		echo
	fi
done
