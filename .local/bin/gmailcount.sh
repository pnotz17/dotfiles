#!/bin/sh
	mail=`curl -su pnotz17:KaDfYnUyjb64XGK https://mail.google.com/mail/feed/atom || echo "<fullcount>unknown number of</fullcount>"`
	mail=`echo "$mail" | grep -oPm1 "(?<=<fullcount>)[^<]+" `
	echo "$mail"