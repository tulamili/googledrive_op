#!/usr/bin/perl
use 5.026 ; use strict; use warnings;
binmode STDOUT, ":utf8";

use HTTP::Request::Common;
use JSON qw/encode_json/;
use LWP::UserAgent;
use Getopt::Std ; getopts 'f:m:' , \my%o ;

$o{f} //= '' ; # フォルダ名
$o{m} //= 'plain/text' ; # 
chomp (my $ACCESS_TOKEN = $ARGV[0] ) ; 
my $GOOGLE_DRIVE_UPLOAD_API = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart" ;

my $mimeType = $o{m} ; 
my $ej = { name => $ARGV[1] , mimeType => $mimeType , $o{f} ne q[] ? (parents  => [ $o{f} ] ): () } ;
my $EJ = encode_json $ej  ; 

my $ua = LWP::UserAgent->new;
my $res = $ua->request(
  POST $GOOGLE_DRIVE_UPLOAD_API,
  'Content-Type' => 'multipart/form-data',
  Authorization =>  "Bearer $ACCESS_TOKEN",
  Content => [
    metadata => [
      undef,
      undef,
      'Content-Type' => 'application/json;charset=UTF-8',
      'Content' => $EJ  #encode_json( %EJ ),
    ],
    file => [ $ARGV[1] ],
  ],
);

print  "\$res->code = ", $res->code . "\n";
print  $res->content . "\n";




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

 $0  -f 目的のフォルダID アクセストークン ファイル名 ..

  2番目はローカルのファイル名
  指定したファイルを指定したGoogleドライブのフォルダーにアップロードする。
  同じ名前のファイルも複数回、このプログラムを実行すると、新規に次々とGoogleドライブにアップロードされる。少し要注意。

 前提的なこと: HTTP::Request::Common を用いる。Net::Google::OAuthを使わない。

  オプション: 
    -f STR : 指定しないか、空文字だと、グーグル直下のディレクトリになる。
    -m TYPE : text/csv　などを指定。 未指定なら plain/text ;

出力例: 

# 200
# {
#  "kind": "drive#file",
#  "id": "19f2RrocH4I3Mdig0LkmNPghJDZnmq35f",
#  "name": "hoge.txt",
#  "mimeType": "plain/text"
# }
