#!/usr/bin/env perl
use 5.030 ; use strict; use warnings;
use HTTP::Tiny ;
use JSON ; use URI::Escape ; use URI ;
use Getopt::Std ; getopts 'g:' , \my%o ;
binmode STDOUT, ":utf8";

my $GOOGLE_DRIVE_API = "https://www.googleapis.com/drive/v3/files";
chomp (my $ACCESS_TOKEN = <> ) ; 
my $count_limit = $o{g} // 2 ; 

# 全てのファイルを取得する
my $uri = URI -> new ( $GOOGLE_DRIVE_API ) ;
$uri -> query_form ( access_token => $ACCESS_TOKEN ) ;
& files ( $uri ) ;

sub files {
    my $uri   = shift;
    my $count = 0 ; # URIの中身から取り出した nextPageToken を引っ張り出した回数
    my $fnum = 0 ; # ファイルの個数
    my $ht    = HTTP::Tiny->new();
    while ( $count < $count_limit ) {
        my $contents = decode_json( $ht->get($uri)->{content} );
        $uri->query_form( access_token => $ACCESS_TOKEN, pageToken => $contents->{nextPageToken} ) ;
        for my $content ( @{ $contents->{files} } ) {
            print "=" x 20 . sprintf (" %06d", ++ $fnum ) . "\n" ;
            printf( "%-8s: %s\n", "id",       $content->{id} );
            printf( "%-8s: %s\n", "name",     $content->{name} );
            printf( "%-8s: %s\n", "mimeType", $content->{mimeType} );
            printf( "%-8s: %s\n", "kind",     $content->{kind} );
            print "=" x 20 . "\n";
        }
        $count ++ ;
        last if ! $contents->{nextPageToken};
        # 最終ページには nextPageToken キーが無い
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

 前提的なこと: HTTP::Tinyを用いる。Net::Google::OAuthを使わない。

 アクセストークンを標準入力に与えたら、ドライブのファイルの一覧を出力。

　オプション : 
    -g N : 何回ページをたぐるか? 未指定なら2。

その他 : 
  1万個ファイルがあると、全部見せるのに、1分間の時間がかかるであろう。