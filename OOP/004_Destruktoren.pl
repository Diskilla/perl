#!/usr/bin/env perl

use strict;
use warnings;

# Klassendefinition (abstrakte Klasse)
{ package Animal;
    use Carp qw( croak );
    use File::Temp qw( tempfile );
    # Konstruktoren
    sub named {
        ref( my $class = shift ) and croak "class name needed";
        my $name = shift;
        my $self = { Name => $name, Color => $class->default_color };
        my ( $fh, $filename ) = tempfile();
        $self->{temp_fh} = $fh;
        $self->{temp_filenme} = $filename;
        bless $self, $class;
    }
    # virtuelle Methoden (Methoden, die in jedem Fall überschrieben werden sollen
    sub default_color { "brown" }
    sub sound { croak "subclass must define sound" }
    # Klassen-/Instanzmethoden
    sub DESTROY {
        my $self = shift;
        my $fh = $self->{temp_fh};
        close $fh;
        unlink $self->{temp_filename};
        print "[",$self->name, " has died.]\n";
    }
    sub speak {
        my $eingabe = shift;
        print $eingabe->name, " goes ", $eingabe->sound, "\n";
    }
    sub name {
        my $eingabe = shift;
        ref $eingabe
            ? $eingabe->{ Name }
            : "an unnamed $eingabe";
    }
    sub color {
        my $eingabe = shift;
        ref $eingabe
            ? $eingabe->{ Color }
            : default_color;
    }
    sub eat {
        my $eingabe = shift;
        my $food = shift;
        print $eingabe->name, " eats $food.\n";
    }
    # reine Instanzmethoden
    sub set_name {
        ref( my $self = shift ) or croak "instance variable needed";
        $self->{ Name } = shift;
    }
    sub set_color {
        ref( my $self = shift ) or croak "instance variable needed";
        $self->{ Color } = shift;
    }
}
# Basisklasse für Scheune (Barn)
{ package Barn;
    sub new { bless [], shift }
    sub add { push @{ +shift }, shift }
    sub contents { @{ +shift } }
    sub DESTROY {
        my $self = shift;
        print "$self is being destroyed...\n";
        for ( $self->contents ) {
            print " ", $_->name, " goes homeless.\n";
        }
    }
}
{ package Barn2;
    sub new { bless [], shift }
    sub add { push @{ +shift }, shift }
    sub contents { @{ +shift } }
    sub DESTROY {
        my $self = shift;
        print "$self is being destroyed...\n";
        while ( @$self ) {
            my $homeless = shift @$self;
            print " ", $homeless->name, " goes homeless.\n";
        }
    }
}
# Subroutine um Kühe zu füttern :-)
sub feed_a_cow_named {
    my $name = shift;
    my $cow = Cow->named( $name );
    $cow->eat( "grass" );
    print "Returning from the subroutine.\n";
}
# Instanzen von Animal
{ package Horse;
    our @ISA = qw( Animal );
    sub sound { "neigh" }
}
{ package Sheep;
    our @ISA = qw( Animal );
    sub sound { "baaah" }
    sub default_color { "white" }
}
{ package Cow;
    our @ISA = qw( Animal );
    sub sound { "moooh" }
    sub default_color { "black-and-white" }
}

my $barn = Barn2->new;
$barn->add( Cow->named( "Bessie" ) );
$barn->add( Cow->named( "Gwen" ) );
print "Burn the barn:\n";
$barn = undef;
print "End of program.\n";
