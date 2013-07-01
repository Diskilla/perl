#!/usr/bin/env perl

# weitere Infos unter: http://goo.gl/Q7NXI

package MyApp::Meta::Attribute::Trait::Labeled;
use Moose::Role;
Moose::Util::meta_attribute_alias('Labeled');

has label => (
    is          => 'rw',
    isa         => 'Str',
    predicate   => 'has_label',
);

package MyApp::Website;
use Moose;

has url => (
    traits      => [qw/Labeled/],
    is          => 'rw',
    isa         => 'Str',
    label       => "The site's URL",
);

has name => (
    is          => 'rw',
    isa         => 'Str',
);

sub dump {
    my $self = shift;

    my $meta = $self->meta;

    my $dump = '';

    for my $attribute ( map { $meta->get_attribute($_) }
        sort $meta->get_attribute_list ) {
            
        if ( $attribute->does('MyApp::Meta::Attribute::Trait::Labeled')
            && $attribute->has_label ) {
            $dump .= $attribute->label;
        } else {
            $dump .= $attribute->name;
        }
        
        my $reader = $attribute->get_read_method;
        $dump .= ": " . $self->$reader . "\n";
    }
    return $dump;
}

package main;

my $app = MyApp::Website->new( url => "http://google.com", name => "Google" );
my $label = $app->meta->get_attribute('url')->label();
print $app->name, "\n", $label, " => ", $app->url, "\n";
