#!/usr/bin/env perl

use strict;
# use warnings;

# Klassendefinition (abstrakte Klasse)
{ package Animal;
    use Carp qw( croak );
    use File::Temp qw( tempfile );
    use WeakRef qw( weaken );
    our %REGISTRY;
    # Konstruktoren
    sub named {
        ref(my $class = shift) and croak "class only";
        my $name = shift;
        my $self = { Name => $name, Color => $class->default_color };
        my ( $fh, $filename ) = tempfile();
        $self->{temp_fh} = $fh;
        $self->{temp_filenme} = $filename;
        bless $self, $class;
        $REGISTRY{ $self } = $self;
        weaken( $REGISTRY{ $self } );
        $self;
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
        delete $REGISTRY{ $self };
    }
    sub registered {
        return map { "a ".ref($_)." named ".$_->name } values %REGISTRY;
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
    sub DESTROY {
        my $self = shift;
        $self->SUPER::DESTROY;
        print "[", $self->name, " has gone off to the glue factory.]\n";
    }
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
{ package RaceHorse;
    our @ISA = qw( Horse );
    dbmopen (our %STANDINGS, "standings", 0666)
        or die "Cannot access standings dbm: $!";
    sub named {
        my $self = shift->SUPER::named(@_);
        my $name = $self->name;
        my @standings = split ' ', $STANDINGS{ $name } || "0 0 0 0";
        @$self{ qw( wins places shows losses ) } = @standings;
        $self;
    }
    sub DESTROY { 
        my $self = shift;
        $STANDINGS{ $self->name } = "@$self { qw( wins places shows losses ) }";
        $self->SUPER::DESTROY;
    }
    # Abgeleitete Klasse um Klassenspezifische Methoden erweitern.
    sub won { shift->{ wins } ++; }
    sub placed { shift->{ places } ++; }
    sub showed { shift->{ shows } ++; }
    sub lost { shift->{ losses } ++; }
    sub standings {
        my $self = shift;
        join ", ", map "$self->{ $_ } $_", qw( wins places shows losses );
    }
}

#~ my $racer = RaceHorse->named( "Billy Boy" );
#~ $racer->won;
#~ $racer->won;
#~ $racer->won;
#~ $racer->showed;
#~ $racer->lost;
#~ print $racer->name, " has standings of: ", $racer->standings, ".\n";
my $runner = RaceHorse->named("Billy Boy");
$runner->won;
$runner->won;
$runner->won;
$runner->won;
$runner->showed;
$runner->placed;
print $runner->name, " has standings ", $runner->standings, ".\n";

my @horses = map Horse->named($_), ("Trigger", "Mr. Ed");
print "alive before block:\n", map(" $_\n", Animal->registered);
{
my @cows = map Cow->named($_), qw(Bessie Gwen);
my @racehorses = RaceHorse->named("Billy Boy");
print "alive inside block:\n", map(" $_\n", Animal->registered);
}
print "alive after block:\n", map(" $_\n", Animal->registered);
print "End of program.\n";
