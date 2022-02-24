#!/usr/bin/perl
use 5.030 ;
use strict;
use warnings;
use Getopt::Std ; getopts 'f:' , \my%o; 
use Net::Google::OAuth;
use Data::Dumper ;

my $CLIENT_ID = "545257978867-91bak1f87u2t5g03609p7koie734hf9i.apps.googleusercontent.com";
my $CLIENT_SECRET = "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";
my $SCOPE  = 'spreadsheets';
my $EMAIL  = 'tulamili@gmail.com';



my $oauth = Net::Google::OAuth->new(
    -client_id     => $CLIENT_ID,
    -client_secret => $CLIENT_SECRET,
);

goto F1 if 1 eq ($o{f}//'') ; 

$oauth->generateAccessToken(
    -scope => $SCOPE,
    -email => $EMAIL,
);

print "This is REFRESH TOKEN:\n";
print "=" x 20 . "\n";
print $oauth->getRefreshToken() . "\n";
print "=" x 20 . "\n";


F1 : 

my $ACCESS_TOKEN = "ya29.A0ARrdaM8UrSdYO3L8Pjs8MsseOyoywfmC-13eT5HgDjTUu36SosHuNQ6IutdBT6dgiDOtOYchw_ANncSk22jQfvW70khrWi2bCE_rFx9w6p6rU5-_D9_2W7lF2QnQWYq2bIt7YR0YRaQLz-iyMiB7uLdFZfq6" ;
my $REFRESH_TOKEN = "1//0eGFj1YgvKGRLCgYIARAAGA4SNwF-L9Ir13scUAWX9qb2uXq4lA9ToTASSfbOiRffEreyAShYuchveaROSihM5r7np5f2e0x2-nk" ;

my $x = Net::Google::OAuth -> refreshToken ( -refresh_token => $REFRESH_TOKEN ) ; 
#my %x=  Net::Google::OAuth -> getTokenInfo (  -access_token => $ACCESS_TOKEN ) ; 


exit 0 ;



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

どう使うか.

1. クライアントIDとクライアントシークレットをプログラムで与えると、URLが表示されて、
それをブラウザで表示すると、アクセストークンとリフレッシュトークンが得られる。確か。

 スプレッドシート用。

=cut
