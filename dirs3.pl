#!/usr/bin/env perl
#use 5.030 ; 
use strict; use warnings;
use feature 'say' ; 
use Data::Dumper ; 
use Getopt::Std ; getopts 'g:/D' , \my%o ;
use HTTP::Tiny ;
use JSON ; use URI::Escape ; use URI ;
binmode STDOUT, ":utf8";

my $GOOGLE_DRIVE_API = "https://www.googleapis.com/drive/v3/files" ;

my $gfile = '~/.gcpsetup2202/1' ; # GCPで使う合言葉を収めたファイルの名前
my $ACCESS_TOKEN = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ;

chomp ( $ACCESS_TOKEN = <> ) if $o{'/'} ; 
my $count_limit = $o{g} // 2 ; 

# 全てのファイルを取得する
my $uri = URI -> new ( $GOOGLE_DRIVE_API ) ;
$uri -> query_form ( access_token => $ACCESS_TOKEN ) ;
& files ( $uri ) ;

sub files {
  my $uri = shift;
  my $count = 0 ; # URIの中身から取り出した nextPageToken を引っ張り出した回数
  my $fnum = 0 ; # ファイルの個数
  my $ht = HTTP::Tiny->new();
  while ( $count < $count_limit ) {
    my $contents = decode_json( $ht->get($uri)->{content} );
    do { print Dumper $contents ; $contents->{error} ? last : next } if $o{D} ;
    $uri->query_form( access_token => $ACCESS_TOKEN, pageToken => $contents->{nextPageToken} ) ;
    for my $content ( @{ $contents->{files} } ) {
      print  sprintf ("%05d ", ++ $fnum ) . "=" x 20 . "\n" ;
      printf( "%-8s: %s\n", "id",     $content->{id} );
      printf( "%-8s: %s\n", "name",   $content->{name} );
      printf( "%-8s: %s\n", "mimeType", $content->{mimeType} );
      printf( "%-8s: %s\n", "kind",   $content->{kind} );
      print "=" x 20 . "\n";
    }
    last if ! $contents->{nextPageToken}; # 最終ページには nextPageToken キーが無い
  }
  continue { 
    $count ++ ;
  }
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

 ドライブのファイルの一覧を出力。何らかの手段でこのプログラムにアクセストークンを与えることが必要。

　オプション : 
  -/   : アクセストークンは、標準入力から読み取る。設定ファイルからではなく。
  -g N : 何回ページをたぐるか? 未指定なら2。
  -D   : 取ってきたデータを Dumper で出力する。エラーが起きたときの様子を調べるのに便利。

その他 : 
  - 1万個ファイルがあると、全部見せるのに、1分間の時間がかかるであろう。
  - 内部で、HTTP::Tinyを用いる。Net::Google::OAuthを使わない。
