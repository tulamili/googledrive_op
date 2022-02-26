#!/usr/bin/perl
#use 5.030 ; 
use strict; use warnings; use Data::Dumper;
use HTTP::Tiny; use JSON; use URI;
use Getopt::Std ; getopts 'aw' , \my%o ; 
my $gfile = '~/.gcpsetup2202/1' ; # GCPで使う合言葉を収めたファイルの名前
my $CLIENT_ID     = qx [ sed -ne's/^CLIENT_ID[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"54.....apps.googleusercontent.com" ;
my $CLIENT_SECRET = qx [ sed -ne's/^CLIENT_SECRET[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # "GOC....." ; 
my $REFRESH_TOKEN = qx [ sed -ne's/^REFRESH_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
#my $ACCESS_TOKEN  = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # 記録したものと比較したい場合のこの行のコードは使うかも。
my $URI = URI->new('https://oauth2.googleapis.com/token'); # $URI = URI->new('https://www.googleapis.com/oauth2/v4/token'); ← どちらでも動く。
my $ht = HTTP::Tiny->new();
my $response = $ht -> request (
  'POST', $URI,
  { content => encode_json( { client_id => $CLIENT_ID, client_secret => $CLIENT_SECRET, grant_type    => 'refresh_token', refresh_token => $REFRESH_TOKEN } ) }
) ;
my $json = decode_json( $response->{content} );
print Dumper $json unless $o{a} ;
my $ACCESS_TOKEN = $json -> {access_token} ;
say $ACCESS_TOKEN if $o{a} ;
qx [ sed -i.bak -e's/^\\(ACCESS_TOKEN[ =:\t]*\\).*\$/\\1$ACCESS_TOKEN/' $gfile ] if $o{w} ; 

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

 主要な機能:
 
   アクセストークンを得て、Dumper で表示する。

オプション: 

  -a : アクセストークンのみを得る。165文字の文字列のみが表示されるであろう。
  -w : 設定ファイルにアクセストークンを書き込む。

 実行結果: 
 
   クライアントIDとクライアントシークレットとレフレッシュトークンから、アクセストークンとその追加情報を得る。

# "access_token": "ya2..(全部で165文字ハイフンピリオドアンダーバー有り英数大文字小文字で、先頭5文字はいつも同じに見える).....g",
# "expires_in": 3599,
# "scope": "https://www.googleapis.com/auth/drive",
# "token_type": "Bearer"

