#!/usr/bin/env perl

# Autor: Josef Florian Sedlmeier
# Datum: 2013/04/07
# IMAP Mail Checker mit SSL

use strict;
use warnings;

# Bibliothek für IMAP mit SSL laden.
# Das Paket libnet-imap-simple-ssl-perl muss installiert sein!
use Net::IMAP::Simple;
use Net::IMAP::Simple::SSL;
use Term::ReadKey;

my $server = 'imap.gmail.com';
print( "Bitte geben Sie Ihre Googlemail-Adresse ein: \n" );
my $user = &getpassphrase;
chomp( $user );
print( "\nBitte geben Sie ihr Googlemail Passwort ein: \n" );
my $pass = <STDIN>;
chomp( $pass );

# Neue Instanz des SSL-Objektes anlegen mit $server als übergebenem Parameter.
my $imap = Net::IMAP::Simple::SSL->new( $server );
# Verbindung zum IMAP-Konto herstellen.
$imap->login( $user => $pass );
# Mails aus Posteingang abrufen und ungelesene zählen.
my $messages = $imap->search_unseen( 'INBOX' );

# Verbindung zum IMAP-Konto wieder trennen.
$imap->quit();

# Ausgabe 
print( "\nUngelesen: ", $messages, "\n" );

# Subroutine um Passworteingabe mit Sternchen zu überschreiben.
sub getpassphrase {
	print "enter passphrase: ";
	ReadMode 'raw';
	my $passphrase;
	while (1) {
		my $key .= (ReadKey 0);
		if ($key ne "\n") {
			print '*';
			$passphrase .= $key
		} else {
			last
		}
	}
	ReadMode 'restore';
	return $passphrase
}	
