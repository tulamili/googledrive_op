#!/usr/bin/perl
# use 5.026 ; 
use strict; use warnings;
use feature 'say' ; 
use HTTP::Request::Common;
use JSON qw/encode_json/;
use LWP::UserAgent;
use Getopt::Std ; getopts 'f:m:' , \my%o ;
binmode STDOUT, ":utf8";
& HELP_MESSAGE if @ARGV == 0 ;
$o{f} //= '' ; # フォルダ名
$o{m} //= 'text/plain' ; # MIMEタイプ
my $gfile = do { use FindBin qw [ $Bin ] ; use lib $FindBin::Bin ; use gdrv ; $gdrv::gfile } ;  # GCPで使う合言葉を収めたファイルの名前
my $ACCESS_TOKEN = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ;
chomp ( $ACCESS_TOKEN = <> ) if $o{'/'} ; #
my $GOOGLE_DRIVE_UPLOAD_API = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart" ;
& f_each ( $_ ) for @ARGV ; 
exit ;

sub f_each ( $ ) { 
  my $mimeType = $o{m} ; 
  my $ej0 = { name => $_[0] , mimeType => $mimeType , $o{f} ne q[] ? ( parents  => [ $o{f} ] ): () } ;
  my $ej1 = encode_json $ej0 ; 
  my $ua = LWP::UserAgent->new ;
  my $res = $ua -> request (
    POST $GOOGLE_DRIVE_UPLOAD_API ,
    'Content-Type' => 'multipart/form-data' ,
    Authorization =>  "Bearer $ACCESS_TOKEN" ,
    Content => [
      metadata => [ undef, undef , 'Content-Type' => 'application/json;charset=UTF-8' , 'Content' => $ej1 ] ,
      file => [ $_[0] ] ,
    ] ,
  ) ;
  print  "\$res->code = ", $res->code . "\n";
  print  $res->content . "\n";
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

 $0  -f 目的のフォルダID ファイル名 [ファイル名] [ファイル名] ..

  指定したファイルを指定したGoogleドライブのフォルダにアップロードする。
  (同じ名前のファイルも複数回、このプログラムを実行すると、新規に次々とGoogleドライブにアップロードされる。少し要注意。)

  このプログラムは HTTP::Request::Common を用いていて、Net::Google::OAuthを使わない。

  オプション: 
    -/     : アクセストークンを標準入力から読み取る。
    -f STR : 指定しないか、空文字だと、グーグル直下のディレクトリになる。
    -m TYPE : text/csv　などを指定。 未指定なら text/plain ;


出力例: 

# 200
# {
#  "kind": "drive#file",
#  "id": "1...(全部で33文字-_英数大文字小文字)bag",
#  "name": "test.txt",
#  "mimeType": "text/plain"
# }
