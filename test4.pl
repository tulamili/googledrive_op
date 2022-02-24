#!/usr/bin/perl
use 5.030 ; use strict; use warnings; use Data::Dumper;
use HTTP::Tiny; use JSON; use URI;
binmode STDIN,  ":utf8";
binmode STDOUT, ":utf8";
#use Carp; #use Net::Google::Drive ;

my $CLIENT_ID = "545257978867-91bak1f87u2t5g03609p7koie734hf9i.apps.googleusercontent.com" ;
   $CLIENT_ID = "545257978867-0isscr9j1mre72cec5d6s8c4n2h4pffp.apps.googleusercontent.com" ;

my $CLIENT_SECRET = "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" ;
   $CLIENT_SECRET = "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" ; 
##my $ACCESS_TOKEN = "ya29.A0ARrdaM_DHHxu_gVdd3gNRlIyamf4Dd1IjQuQC2AtruB08WIFcP17gNkPfYcv6TyuyBj5P_j5GgD3FBFGE6HWDExCm8wwy95VoupjP65rdQ9Kl7XHG0DOZ7de--zuJ6QVtLmWQan9_bRm0VIj4W9WpOqX3-Ft" ;
#ya29.A0ARrdaM8UiAUalVHOW8--hpxQCUmov1e5onzA65RQlbbqgqSiIkdd2Y_ZzS_Iu2cQQ9pPGj5Ojet6V2vR4V-QUTQ_xwHCxsOHygewISLBMq4CyxA7u7Fgma0UsUDwoK1Tyyje3uFHuHA2yFIXhKat-2WBrQYJ

my $REFRESH_TOKEN = "1//0eBucL-LK6gVfCgYIARAAGA4SNwF-L9Irp8vmmpll_z4-gclBdE35mKr7cS6E9VoGEeLwduPjNisKO0foPIAevdorxNC8mNoXsKA" ;
   $REFRESH_TOKEN = "1//0eXdDPal8s0cWCgYIARAAGA4SNwF-L9Irnn1aEtXn8HHX_WrlgjanBj9nE4V1NwAwzTr59LaGWZfKTSG0lazBkRxhyPoaEZPsKCk" ;
   $REFRESH_TOKEN = "1//0eGFj1YgvKGRLCgYIARAAGA4SNwF-L9Ir13scUAWX9qb2uXq4lA9ToTASSfbOiRffEreyAShYuchveaROSihM5r7np5f2e0x2-nk" ;
my $URI = URI->new('https://oauth2.googleapis.com/token');
#  $URI = URI->new('https://www.googleapis.com/oauth2/v4/token');
my $ht = HTTP::Tiny->new();
my $response = $ht->request(
    'POST', $URI,
    {   content => encode_json(
            {   client_id     => $CLIENT_ID,
                client_secret => $CLIENT_SECRET,
                grant_type    => 'refresh_token',
                refresh_token => $REFRESH_TOKEN,
            }
        )
    }
) ;

my $json = decode_json($response->{content});
print Dumper $json;



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


# "access_token": "hogehogefoofoobarbar",
# "expires_in": 3599,
# "scope": "https://www.googleapis.com/auth/drive",
# "token_type": "Bearer"
