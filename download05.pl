#!/usr/bin/perl
#use 5.030 ; 
use strict; use warnings ;
use feature 'say' ;
use Data::Dumper ;
use Carp ;
use Net::Google::Drive ;
use Getopt::Std ; getopts 'f:',\my%o ;
& HELP_MESSAGE if @ARGV != 2 ;
binmode STDOUT, ":utf8" ; # binmode STDIN,  ":utf8"　;
my $gfile = '~/.gcpsetup2202/1' ; # GCPで使う合言葉を収めたファイルの名前
my $CLIENT_ID     = qx [ sed -ne's/^CLIENT_ID[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"54525797.....34dseo.apps.googleusercontent.com" ;
my $CLIENT_SECRET = qx [ sed -ne's/^CLIENT_SECRET[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # "GOCSP...YUbpe1" ; 
my $REFRESH_TOKEN = qx [ sed -ne's/^REFRESH_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
my $ACCESS_TOKEN  = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; 
my $disk = Net::Google::Drive->new(  -client_id => $CLIENT_ID, -client_secret => $CLIENT_SECRET, -access_token  => $ACCESS_TOKEN, -refresh_token => $REFRESH_TOKEN, );
# ファイル一覧を出力。
$disk->downloadFile( -file_id => $ARGV[0], -dest_file => $ARGV[1] ) or croak "Failure to download.";
exit ; 

# my $r = $disk->uploadFile(-dest_file => './test.txt', -parents   => ['folder'] ) ; # アップロードの場合. file_id などが返り値

=encoding utf8

=head1

 $0 file_id local_destination 

   グーグルドライブの1個のファイルをローカルにダウンロードする。
   file_idは33文字。(file_idが44文字の場合はうまくいかないようだ。)
   

開発メモ: 
   * ダウンロードするファイルの様々な情報を画面に出したい。
   * もう少し情報を親切にしたいかも。

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

