#!/usr/bin/perl
use 5.026 ; use strict ; use warnings ;
use HTTP::Request::Common ;
use JSON qw/encode_json/ ;
use LWP::UserAgent ;
use URI::QueryParam ;
use URI ;
use Getopt::Std ; getopts 'i:',\my%o ;

& HELP_MESSAGE if @ARGV == 0  ; 
#my $target_fileid = $ARGV[0] ;

my $GOOGLE_DRIVE_UPLOAD_API = "https://www.googleapis.com/upload/drive/v3/files/";
my $gfile = '~/.gcpsetup2202/1' ; # GCPで使う合言葉を収めたファイルの名前
my $ACCESS_TOKEN = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ;
chomp ( $ACCESS_TOKEN = <> ) if $o{'/'} ; # my $ACCESS_TOKEN = $ARGV[0] ;
my $bearer = join ' ', ( 'Bearer', $ACCESS_TOKEN );

& f_each ( split /:/, $_ , 2 ) for ( @ARGV ) ; 

exit 0 ; 

sub f_each ( $$ ) { 
  my $URI = URI->new( $GOOGLE_DRIVE_UPLOAD_API . $_[0] );
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
      file => [ $_[1] ] #["./hoge.txt"],
    ],
  );

  print $res->code . "\n";
  print $res->content . "\n";
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

 $0  ファイルID:ファイル名 [ファイルID:ファイル名] [ファイルID:ファイル名] .. 

  指定したファイルを指定したGoogleドライブのフォルダーにアップロードする。
  各引数の書式は次のようになる。
    グーグルドライブ上のファイルID : ローカルのファイル名

 前提的なこと: 
    このプログラムは、HTTP::Request::Common を用いる。Net::Google::OAuthを使っていない。

  オプション: 

   -/ : アクセストークンを標準入力から読み取る。


  開発上のメモ: 
    複数のファイルに対応したい。


# 200
# {
#  "kind": "drive#file",
#  "id": "19f2RrocH4I3Mdig0LkmNPghJDZnmq35f",
#  "name": "hoge.txt",
#  "mimeType": "plain/text"
# }
