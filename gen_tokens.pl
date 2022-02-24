#!/usr/bin/perl
use 5.030 ;
use strict;
use warnings;
use Getopt::Std ; getopts 'f:', \my%o ;
use Net::Google::OAuth;

my $CLIENT_ID = "545257978867-tt7539v8nuejtk6ng44en80l6334dseo.apps.googleusercontent.com" ;
my $CLIENT_SECRET = "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" ; 
my $SCOPE  = 'drive'; #my $SCOPE  = 'spreadsheets';
my $EMAIL  = 'tulamili@gmail.com';

do { & main_another ; exit } if 1 eq ($o{f} //'') ;
do { & main_orig () ; exit } 

sub main_orig () { 
    my $oauth = Net::Google::OAuth->new(    -client_id     => $CLIENT_ID,    -client_secret => $CLIENT_SECRET ) ;
    $oauth->generateAccessToken(    -scope => $SCOPE,    -email => $EMAIL,) ;
    print "This is ACCESS TOKEN:\n"; print "=" x 20 . "\n"; print $oauth->getAccessToken() . "\n"; print "=" x 20 . "\n";
    print "This is REFRESH TOKEN:\n";  print "=" x 20 . "\n"; print $oauth->getRefreshToken() . "\n"; print "=" x 20 . "\n";
}

sub main_another() { 
  my $oauth = Net::Google::OAuth->new(    -client_id     => $CLIENT_ID,    -client_secret => $CLIENT_SECRET ) ;
  my $x1 = $oauth -> refreshToken ( -refresh_token => "1//0e8i8kRu5P0PWCgYIARAAGA4SNwF-L9IrZ-F0zJbFcPqIWyVahL0Gtp5spr5yCPM5oXRszgU-SdEkdyVXuKLt8pPyLDJyrKxXNJY" )  ;
  my $x2 = $oauth -> getAccessToken () ;
  say $x2 ;
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

   有効なクライアントIDとクライアントシークレットから、
   アクセストークンと、リフレッシュトークンを得ることができる。

   → 手動作業が、追加で必要。
   → URLを生成して、ブラウザに表示させて、
     2回意味のあるクリックをしたら、ブラウザのURL欄に現れるhttp://localhost:8000/?state=uniq_state_36113&code= のような
     文字列が現れて、それを再び$0 にコピペすることで上記が実行出来る。
   

 別の動作( -f1 の視程による ) : 
   リフレッシュトークン(半年間有効)から、1時間有効なアクセストークンを生成する(標準出力に出力する)。
    → 約160文字。実行する度に異なるアクセストークンが生成される。
    → ブラウザを用いた認証は必要としないので、手動の作業を必要とはしない。