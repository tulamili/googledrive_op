#!/bin/zsh

FILE=~/.gcpsetup2202/1
touch $FILE 
chmod 600 $FILE # 他のユーザーに書き込んだファイルは見えないようにする。 

cat > $FILE <<EOF
##
## このファイルは、キーとバリューの形式で情報を読み取るプログラムに使われる。
##  * キーとバリューの間は 半角空白、タブ文字、コロン(:)、イコール文字(=)とその組合せのみが許容される。
##  * バリューの文字列は、改行文字の直前までであることを想定している。
##  * コメントアウトの書式は想定されない。
##  * バリュー(値;左から2列目)を削除したい場合、その左側の1列(キー)を表す文字列は残すこと。後で再び何かのプログラムが書き込むことがあるからである。
##

EMAIL			txxxxx@xyz.jp

# 次の2個は、デスクトップクライアント2として取得。2022年2月17日に。

CLIENT_ID		545....u(全長72文字)sercontent.com
CLIENT_SECRET   GO..(全長35文字)..GYUbpe1

# アクセストークンは60分ごと、リフレッシュトークンは6ヶ月ごとに更新しないと、使えなくなる。

REFRESH_TOKEN	1//0e...(103文字;途中で2個のスラッシュ文字を含む。sedやperlでs関数を使う時など区切り文字に気をつけること)..
ACCESS_TOKEN	ya29....(165文字)...................................................

EOF
