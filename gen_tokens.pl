#!/usr/bin/perl
use 5.030 ;
use strict;
use warnings;
use Getopt::Std ; getopts 'arw', \my%o ;
use Net::Google::OAuth;

my $gfile = '~/.gcpsetup2202/1' ; # GCPで使う合言葉を収めたファイルの名前

my $CLIENT_ID     = qx [ sed -ne's/^CLIENT_ID[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"54525797.....34dseo.apps.googleusercontent.com" ;
my $CLIENT_SECRET = qx [ sed -ne's/^CLIENT_SECRET[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # "GOCSP...YUbpe1" ; 
my $EMAIL         = qx [ sed -ne's/^EMAIL[ =:\t]*//p' $gfile ] =~ s/\n$//r ;
my $SCOPE         = 'drive'; #my $SCOPE  = 'spreadsheets';

do { & main_orig () ; exit } unless $o{a} || $o{r} ;

my $REFRESH_TOKEN = qx [ sed -ne's/^REFRESH_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"1//0e8......yLDJyrKxXNJY" ; 
do { say $REFRESH_TOKEN ; exit } if $o{r} ;
do { & main_another ; exit } if $o{a} ;


# クライアントID とクライアントシークレット、メールアドレス、スコープ(計4個の情報)から、アクセストークンとリフレッシュトークンを表示する。
sub main_orig () { 
    say 'Paste the following url into your browser. Push "Continue" button twice. Then copy the URL on your browser to paste here.' ;
    my $oauth = Net::Google::OAuth->new(    -client_id     => $CLIENT_ID,    -client_secret => $CLIENT_SECRET ) ;
    $oauth->generateAccessToken(    -scope => $SCOPE,    -email => $EMAIL,) ;
    my $ACCESS_TOKEN = $oauth -> getAccessToken () ;
    my $REFRESH_TOKEN = $oauth -> getRefreshToken () ; 
    print "This is ACCESS TOKEN:\n"; print "=" x 20 . "\n"; print $ACCESS_TOKEN . "\n"; print "=" x 20 . "\n" ;
    print "This is REFRESH TOKEN:\n";  print "=" x 20 . "\n"; print $REFRESH_TOKEN . "\n"; print "=" x 20 . "\n" ;
    qx [ sed -i.bak -e's|^\\(REFRESH_TOKEN[ =:\t]*\\).*\$|\\1$REFRESH_TOKEN|' $gfile ] if $o{w} ; # リフレッシュトークンでは途中で/があるので、このsed文では/を使わず|を用いた。
    qx [ sed -i.bak -e's/^\\(ACCESS_TOKEN[ =:\t]*\\).*\$/\\1$ACCESS_TOKEN/' $gfile ] if $o{w} ; 
}

# クライアントIDとクライアントシークレット、リフレッシュトークン(計3個の情報)から、アクセストークンを取得する。
sub main_another() { 
  my $oauth = Net::Google::OAuth->new(    -client_id     => $CLIENT_ID,    -client_secret => $CLIENT_SECRET ) ;
  my $x1 = $oauth -> refreshToken ( -refresh_token => $REFRESH_TOKEN )  ;
  my $ACCESS_TOKEN = $oauth -> getAccessToken () ;
  say $ACCESS_TOKEN ;
  qx [ sed -i.bak -e's/^\\(ACCESS_TOKEN[ =:\t]*\\).*\$/\\1$ACCESS_TOKEN/' $gfile ] if $o{w} ; 
  # qxが\を解釈するので、この行を編集するときは要注意。
  # qxに sed で行末を表す$を渡す際に、$が何かPerlの変数として解釈されないように、\が前に必要。
  # sed では Mac だと -i に引数が必要。
  # sed では、\1 にキャプチャするための括弧は、元々\が必要。それをqxに渡す場合に\をさらに前に追加。
}


## ヘルプ (オプション --help が与えられた時に、動作する)
sub VERSION_MESSAGE {}
sub HELP_MESSAGE {
  use FindBin qw[ $Script ] ; 
  $ARGV[1] //= '' ;
  open my $FH , '<' , $0 ;
  while(<$FH>){
    s/\$0/$Script/g ;
    print $_ if s/^=head1// .. s/^=cut// and $ARGV[1] =~ /^o(p(t(i(o(ns?)?)?)?)?)?$/i ? m/^\s+\-/ : 1;
  }
  close $FH ;
  exit 0 ;
}

=encoding utf8

=head1

 $0 

 前提的なこと : Net::Google::OAuth を使う。

 元々の動作 :

   ~/.gcpsetup2202/1 (パーミッションを600に設定)有効なクライアントIDとクライアントシークレットから、
   アクセストークンと、リフレッシュトークンを得ることができる。

   → 手動作業が、追加で必要。
   → URLを生成して、ブラウザに表示させて、
     2回意味のあるクリックをしたら、ブラウザのURL欄に現れるhttp://localhost:8000/?state=uniq_state_36113&code= のような
     文字列が現れて、それを再び$0 にコピペすることで上記が実行出来る。
   

 別の動作( -a の視程による ) : 
   リフレッシュトークン(半年間有効)から、1時間有効なアクセストークンを生成する(標準出力に出力する)。
    → 約160文字。実行する度に異なるアクセストークンが生成される。
    → ブラウザを用いた認証は必要としないので、手動の作業を必要とはしない。

  オプション: 
    -a : リフレッシュトークンから、アクセストークンを得る。(約160文字)
    -r : 単に記録されているリフレッシュトークンを出力する。(約100文字)
    -w : 設定ファイルに書込を実行する。


