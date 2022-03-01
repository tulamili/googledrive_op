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
my $cid = qx [ sed -ne's/^CLIENT_ID[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"54525797.....34dseo.apps.googleusercontent.com" ;
my $csec = qx [ sed -ne's/^CLIENT_SECRET[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # "GOCSP...YUbpe1" ; 
my $rtoken = qx [ sed -ne's/^REFRESH_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
my $atoken  = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
my $disk = Net::Google::Drive->new(  -client_id => $cid, -client_secret => $csec, -access_token  => $atoken, -refresh_token => $rtoken, );
# ファイル一覧を出力。
my $file_name = $o{f} ; ## アスタリスクで全部のファイルの情報を取ってくる。ただし最大100個のようである。
my $files = $disk->searchFileByNameContains( -filename => $file_name ) or croak "File '$file_name' not found";
my $fnum = 0 ;
#do { say '=' x 20 . sprintf (' %04d', ++ $fnum) ; say $_->{id}; say $_->{name}; say $_->{mimeType}; say $_->{kind}; say '=' x 20 } for @{$files} ;
do { say join"\t",sprintf('%03d',++$fnum),$_->{kind},$_->{id},qq["$_->{name}"],$_->{mimeType} } for @{$files} ;

# # ファイルダウンロード
# # -dest_file ：保存先（ローカル）でのファイル名
# # -file_id   ：ダウンロードしたいGoogle Drive上のコンテンツ
# $disk->downloadFile(
#     -dest_file => './branches.csv',
#     -file_id   => '1juzsinLmryTufEIY53h3nuFPaq_l4Lxn',
#     );
# # ファイルアップロード
# # -dest_file ：アップロードしたいファイル（のパス）
# # -parents   ：Google Drive上のフォルダの下に格納するかを指定
# # 無指定の場合はトップに保存
# # フォルダIDはフォルダURLの後半のところ
# # https://drive.google.com/drive/folders/{Google Drive上のフォルダID}

# my $res = $disk->uploadFile(
#     -source_file => './test.txt',
#     -parents   => ['hogehogefuga'], # 配列リファレンスの中に指定すること
#     );
# # アップロードしたファイルの file_id などが返ってくる

=encoding utf8

=head1

 $0 
   アクセストークンは標準入力から。(メアドは不要。4個の情報が必要。)
   Net::Google::Drive を使う。
   最大100個のファイルを取り出す。

   ワイルドカードを使ったファイル名で検索ができる。IDを突き止めることが出来る。

オプション: 
    -f ファイル名(ワイルドカードなどか使える様だが) 

開発メモ: 
   * そのファイルの親フォルダとか、あるフォルダが含むファイルとかの情報も欲しい。
   * 検索するとしても、1.3万個のファイルから取り出してくれるのだろうか? 限られた特定の100個だけからということは無かろうか?
   * ファイルアップ/ダウンロードの機能のヒントは、このプログラム内にコメントとして残した。

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

