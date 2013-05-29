#!/usr/bin/env perl

# Autor: Josef Florian Sedlmeier
# Datum: 2013/05/28
# CSV-Datei aus Array erstellen (using File::Find)

use strict;
use warnings;

use Log::Log4perl qw( :easy );
use File::Find;

# Initialisieren von Log4perl.
Log::Log4perl->easy_init( $DEBUG );

my $dir = "/home/extcjs/Bilder";
my @dateien;
# mit File::Find und einer anonymen Funktion als Parameter den Ordner durchsuchen
# und das Ergebnis in das Array @dateien schreiben, wenn es nicht mit '.' oder 
# '..' beginnt. 
# Der Reguläre Ausdruck '/^.*(?:jpg|gif|png)$/' prüft, ob die Dateiendung jpg,
# gif oder png ist damit nur diese Dateien zurückgegeben werden.
find(sub { if ( ($_ !~ m/^\..*/) and ( $_ =~ /^.*(?:jpg|gif|png)$/ ) and (-f $_) ){
                push @dateien, $_
                }
         }, $dir
    );
print "Verzeichnis gelesen!\n";
# Den Inhalt von @dateien aufsteigend sortieren und mit der Funktion 'csv' weiter
# bearbeiten.
my @gesuchteDateien = &csv(sort(@dateien));
# Das (nun mit Kommas getrennte) Array anschließend in die Datei 'output.csv'
# schreiben. 
&open_file_to_write(@gesuchteDateien);
print "Datei './output.csv' erstellt!\n";
# Subroutine um eine csv-Liste zu erstellen.
sub csv {
    my @csvEintraege = join (",", @_);
    return @csvEintraege;
}
# Subroutine um die Datei 'output.csv' zu öffnen und das übergebene Array rein
# zu schreiben.
sub open_file_to_write {
    my $csv = "output.csv";
    open (DATEI, ">$csv") or die $!;
    print DATEI ( @_ );
    close (DATEI);
}
