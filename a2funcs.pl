#!/usr/bin/perl
use 5.030 ; use strict; use warnings;
use Data::Dumper;
use Carp;
use Net::Google::Drive ;
use Getopt::Std ; getopts 'f:',\my%o ;
$o{f} //= '*' ; # 探すファイルの名前(と思われる)

binmode STDOUT, ":utf8"; # binmode STDIN,  ":utf8";

my $CLIENT_ID = "545257978867-tt7539v8nuejtk6ng44en80l6334dseo.apps.googleusercontent.com" ;
my $CLIENT_SECRET = "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" ; 
my $REFRESH_TOKEN = "1//0e8i8kRu5P0PWCgYIARAAGA4SNwF-L9IrZ-F0zJbFcPqIWyVahL0Gtp5spr5yCPM5oXRszgU-SdEkdyVXuKLt8pPyLDJyrKxXNJY" ; 
chomp (my $ACCESS_TOKEN = <> ) ; # chompはせずとも、動作はした。
my $disk = Net::Google::Drive->new(  -client_id => $CLIENT_ID, -client_secret => $CLIENT_SECRET, -access_token  => $ACCESS_TOKEN, -refresh_token => $REFRESH_TOKEN, );

# ファイル一覧
my $file_name = $o{f} ; #'11_読み物/121010fukui.pdf';    # アスタリスクで全部のファイルの情報を取ってくる
my $files = $disk->searchFileByNameContains( -filename => $file_name ) or croak "File '$file_name' not found";
my $fnum = 0 ;
for my $file ( @{$files} ) {
    say '=' x 20 . sprintf (' %04d', ++ $fnum) ; say $file->{id}; say $file->{name}; say $file->{mimeType}; say $file->{kind};
    say '=' x 20; # Googleドライブの、フォルダは、mimeTypeは、application/vnd.google-apps.folder になる。
}


=encoding utf8

=head1

 $0 
   アクセストークンは標準入力から。
   Net::Google::Drive を使う。
   100個のファイルを取り出す。

   ワイルドカードを使ったファイル名で検索ができる。IDを突き止めることが出来る。
   (そのファイルの親フォルダとか、あるフォルダが含むファイルとかの情報も欲しいのだが。)

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
# say Dumper $res;