#!/usr/bin/perl
use 5.026 ; use strict ; use warnings ;
use HTTP::Request::Common ;
use JSON qw/encode_json/ ;
use LWP::UserAgent ;
use URI::QueryParam ;
use URI ;
use Getopt::Std ; getopts 'i:',\my%o ;

& HELP_MESSAGE if @ARGV < 3 ; 
my $target_fileid = $ARGV[1] ;

my $GOOGLE_DRIVE_UPLOAD_API = "https://www.googleapis.com/upload/drive/v3/files/";
my $ACCESS_TOKEN = $ARGV[0] ;
my $bearer = join ' ', ( 'Bearer', $ACCESS_TOKEN );
my $URI = URI->new( $GOOGLE_DRIVE_UPLOAD_API . $target_fileid );
$URI->query_param( uploadType => 'multipart' );

my $ua  = LWP::UserAgent->new;
my $res = $ua->request(
  PATCH $URI,
  'Content-Type' => 'multipart/form-data',
  Authorization  => $bearer,
  Content    => [

    metadata => [
      undef, undef,
      'Content-Type' => 'application/json;charset=UTF-8',
      'Content'    => encode_json(
        {
          # name   => 'hogefuga.txt',
          #  mimeType => 'plain/text',
          #  parents  => ['10kCqEUmWsWlqMdP_vF9pDGrQXFVZ-Lvr'],
          #  id => $target_fileid,
        },
      ),
    ],

    file => [ $ARGV[2] ] #["./hoge.txt"],
  ],
);

print $res->code . "\n";
print $res->content . "\n";



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

 $0  アクセストークン ファイルID ファイル名

  2番目はローカルのファイル名
  指定したファイルを指定したGoogleドライブのフォルダーにアップロードする。
  同じ名前のファイルも複数回、このプログラムを実行すると、新規に次々とGoogleドライブにアップロードされる。少し要注意。

 前提的なこと: HTTP::Request::Common を用いる。Net::Google::OAuthを使わない。

  オプション: 


# 200
# {
#  "kind": "drive#file",
#  "id": "19f2RrocH4I3Mdig0LkmNPghJDZnmq35f",
#  "name": "hoge.txt",
#  "mimeType": "plain/text"
# }
