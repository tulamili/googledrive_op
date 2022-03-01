#!/usr/bin/perl
#use 5.030 ; 
use strict; use warnings ;
use feature 'say' ;
use Data::Dumper ;
use Carp ;
use Net::Google::Drive ;
use Getopt::Std ; getopts 'f:',\my%o ;
$o{f} //= '*' ; # 探すファイルの名前(のようである)
binmode STDOUT, ":utf8" ; # binmode STDIN,  ":utf8"　;
my $gfile = do { use FindBin qw [ $Bin ] ; use lib $FindBin::Bin ; use gdrv ; $gdrv::gfile } ;  # GCPで使う合言葉を収めたファイルの名前
my $cid = qx [ sed -ne's/^CLIENT_ID[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"54...34dseo.apps.googleusercontent.com" ;
my $csec = qx [ sed -ne's/^CLIENT_SECRET[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # "GOCSP...YUbpe1" ; 
my $rtoken = qx [ sed -ne's/^REFRESH_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
my $atoken = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
my $disk = Net::Google::Drive->new( -client_id => $cid, -client_secret => $csec, -access_token  => $atoken, -refresh_token => $rtoken );
# ファイル一覧を出力。
my $file_name = $o{f} ; ## アスタリスクで全部のファイルの情報を取ってくる。ただし最大100個のようである。
my $files = $disk->searchFileByNameContains( -filename => $file_name ) or croak "File '$file_name' not found";
my $fnum = 0 ;
do { say join"\t",sprintf('%03d',++$fnum),$_->{kind},$_->{id},qq["$_->{name}"],$_->{mimeType} } for @{$files} ;

=encoding utf8

=head1

 $0 
   アクセストークンは標準入力から。(メアドは不要。4個の情報が必要。)
   Net::Google::Drive を使う。
   最大100個のファイルを取り出す。

   ワイルドカードを使ったファイル名で検索ができる。IDを突き止めることが出来る。

オプション: 
    -f ファイル名(ワイルドカードなどが使える;要精査) 

開発メモ: 
   * そのファイルの親フォルダとか、あるフォルダが含むファイルとかの情報も欲しい。
   * ~検索するとしても、1.3万個のファイルから取り出してくれるのだろうか? 限られた特定の100個だけからということは無かろうか?~

=cut

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

