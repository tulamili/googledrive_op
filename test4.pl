#!/usr/bin/perl
use 5.030 ; use strict; use warnings; use Data::Dumper;
use HTTP::Tiny; use JSON; use URI;
use Getopt::Std ; getopts 'a' , \my%o ; 
#binmode STDIN,  ":utf8";
#binmode STDOUT, ":utf8";

my $CLIENT_ID = "545257978867-tt7539v8nuejtk6ng44en80l6334dseo.apps.googleusercontent.com" ;
my $CLIENT_SECRET = "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" ; 
my $REFRESH_TOKEN = "1//0e8i8kRu5P0PWCgYIARAAGA4SNwF-L9IrZ-F0zJbFcPqIWyVahL0Gtp5spr5yCPM5oXRszgU-SdEkdyVXuKLt8pPyLDJyrKxXNJY" ; 
my $URI = URI->new('https://oauth2.googleapis.com/token'); # $URI = URI->new('https://www.googleapis.com/oauth2/v4/token'); ← どちらでも動く。

my $ht = HTTP::Tiny->new();
my $response = $ht -> request (
  'POST', $URI,
  { content => 
    encode_json( { client_id => $CLIENT_ID, client_secret => $CLIENT_SECRET, grant_type    => 'refresh_token', refresh_token => $REFRESH_TOKEN } )
  }
) ;

my $json = decode_json( $response->{content} );
print Dumper $json unless $o{a} ;
say $json->{access_token} if $o{a} ;



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

下記のような結果を得る。クライアントIDとクライアントシークレットとレフレッシュトークンから、アクセストークンとその追加情報を得る。

# "access_token": "hogehogefoofoobarbar",
# "expires_in": 3599,
# "scope": "https://www.googleapis.com/auth/drive",
# "token_type": "Bearer"

オプション: 
  -a : アクセストークンのみを得る。