if [ "$1"x = x ]
then
	echo "need message"
else
	git add -A
	git commit -m $1
	if [ "$2"x != x ]
	then
		git push origin master
	fi
fi
