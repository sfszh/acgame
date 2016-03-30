#!/usr/bin/env perl

use 5.10.0;
use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse  = 1;

GetOptions(
  'depth=i' => \(my $DEPTH = 3),
) or die "Bad options";
$DEPTH = 3 if $DEPTH < 1;

my %actions = (
  #subquest => [
  #    { description => 'Go someplace', sequence => ['goto'] },
  #    {   description => 'Go perform a quest and return', sequence    => [ 'goto', 'QUEST', '>goto' ]
  #    },
  #],
  goto => [

    #{ description => 'You are already there', sequence => [ '*' ] },
    {   description => 'Just wander around and look',
      sequence    => ['>explore']
    },
    {   description => 'Find out where to go and go there',
      sequence    => [ 'learn', '>goto' ]
    },
  ],
  learn => [

#{ description => 'You already know it', sequence => [ '*' ] },
#{ description => 'Go someplace, perform subquest, get info from NPC', sequence => [ 'goto', 'subquest', '>listen'  ] },
    {   description =>
      'Go someplace, get something, and read what is written on it',
      sequence => [ 'goto', 'get', '>read' ]
    },

#{ description => 'Get something, perform subquest, give to NPC in return for info', sequence => [ 'get', 'subquest', '>give', '>listen'  ] },
  ],
  get => [

    #{ description => 'You already have it' => sequence => ['*'] },
    { description => 'Steal it from somebody', sequence => ['steal'] },
    {   description =>
      'Go someplace and pick something up that’s lying around there',
      sequence => [ 'goto', '>gather' ]
    },

#{ description => 'Go someplace, get something, do a subquest for somebody, return and exchange', sequence => [ 'goto', 'get', 'goto', 'subquest', '>exchange'  ] },
  ],
  steal => [
    {   description =>
      'Go someplace, sneak up on somebody, and take something',
      sequence => [ 'goto', '>stealth', '>take' ]
    },
    {   description => 'Go someplace, kill somebody and take something',
      sequence    => [ 'goto', 'kill', '>take' ]
    },
  ],
  spy => [
    {   description => 'Go someplace, spy on somebody, return and report',
      sequence    => [ 'goto', '>spy', 'goto', '>report' ]
    },
  ],
  capture => [
    {   description =>
      'Get something, go someplace and use it to capture somebody',
      sequence => [ 'get', 'goto', '>capture' ]
    },
  ],
  kill => [
    {   description => 'Go someplace and kill somebody',
      sequence    => [ 'goto', '>kill' ]
    },
  ],
);

my %motivations = (
  knowledge => [
    {   description => 'Deliver item for study',
      sequence    => [ 'get', 'goto', '>give' ]
    },
    { description => 'Spy', sequence => ['spy'] },
    {   description => 'Interview NPC',
      sequence    => [ 'goto', '>listen', 'goto', '>report' ]
    },
    {   description => 'Use an item in the field',
      sequence    => [ 'get', 'goto', '>use', 'goto', '>give' ]
    },
  ],
  comfort => [
    {   description => 'Obtain luxuries', sequence => [qw/get goto >give/]
    },
    {   description => 'Kill pests',
      sequence    => [qw/goto >damage goto >report/]
    },
  ],
  reputation => [
    {   description => 'Obtain rare items',
      sequence    => [qw/get goto >give/]
    },
    {   description => 'Kill enemies',
      sequence    => [qw/goto kill goto >report/]
    },
    {   description => 'Visit a dangerous place',
      sequence    => [qw/goto goto >report/]
    },
  ],
  serenity => [
    { description => 'Revenge, justice', sequence => [qw/goto >damage/] },
    {   description => 'Capture Criminal(1)',
      sequence    => [qw/get goto >use goto >give/]
    },
    {   description => 'Capture Criminal(2)',
      sequence    => [qw/get goto >use >capture goto >give/]
    },
    {   description => 'Check on NPC(1)',
      sequence    => [qw/goto >listen goto >report/]
    },
    {   description => 'Check on NPC(2)',
      sequence    => [qw/goto >take goto >give/]
    },
    {   description => 'Recover lost/stolen item',
      sequence    => [qw/get goto >give/]
    },
    {   description => 'Rescue captured NPC',
      sequence    => [qw/goto >damage >escort goto >report/]
    },
  ],
  protection => [
    {   description => 'Attack threatening entities',
      sequence    => [qw/goto >damage goto >report/]
    },
    {   description => 'Treat or repair (1)',
      sequence    => [qw/get goto >use/]
    },
    {   description => 'Treat or repair (2)',
      sequence    => [qw/goto >repair/]
    },
    {   description => 'Create Diversion (1)',
      sequence    => [qw/get goto >use/]
    },
    {   description => 'Create Diversion (2)',
      sequence    => [qw/goto >damage/]
    },
    {   description => 'Assemble fortiﬁcation',
      sequence    => [qw/goto >repair/]
    },
    { description => 'Guard entity', sequence => [qw/goto >defend/] },
  ],
  conquest => [
    { description => 'Attack enemy', sequence => [qw/goto >damage/] },
    {   description => 'Steal stuﬀ',
      sequence    => [qw/goto steal goto >give/]
    },
  ],
  wealth => [
    { description => 'Gather raw materials', sequence => [qw/goto get/] },
    {   description => 'Steal valuables for resale',
      sequence    => [qw/goto steal/]
    },
    {   description => 'Make valuables for resale',
      sequence    => [qw/>repair/]
    },
  ],
  ability => [    # lower level missions, generally
    {   description => 'Assemble tool for new skill',
      sequence    => [qw/>repair >use/]
    },
    {   description => 'Obtain training materials',
      sequence    => [qw/>get >use/]
    },
    { description => 'Use existing tools',  sequence => [qw/>use/] },
    { description => 'Practice combat',     sequence => [qw/>damage/] },
    { description => 'Practice skill',      sequence => [qw/>use/] },
    { description => 'Research a skill(1)', sequence => [qw/get >use/] },
    {   description => 'Research a skill(2)',
      sequence    => [qw/get >experiment/]
    },
  ],
  equipment => [
    { description => 'Assemble', sequence => [qw/>repair/] },
    {   description => 'Deliver supplies',
      sequence    => [qw/get goto >give/]
    },
    { description => 'Steal supplies', sequence => [qw/steal/] },
    {   description => 'Trade for supplies',
      sequence    => [qw/goto >exchange/]
    },
  ],
);

validate( \%actions, \%motivations );

my %generated_subs;

my $current_depth = 0;

foreach my $action ( keys %actions ) {
  $generated_subs{$action} = sub {
    my ( $description, @choice ) = randomly_choose( $actions{$action} );
    $current_depth++;
    my $padding = '    ' x $current_depth;
    if ( $current_depth + 1 > $DEPTH ) {
      @choice = grep {/^>/} @choice;
    }
    say "$padding\[$description] " . Dumper( \@choice );

    foreach my $step (@choice) {
      say "$padding$step";
      if ( $step =~ /^\w/ ) {
        $generated_subs{$step}->();
      }
    }
    $current_depth--;
  };
}

my @motivations = keys %motivations;
my $motivation  = $motivations[ rand @motivations ];
my ( $description, @choice ) = randomly_choose( $motivations{$motivation} );

say "Generating a quest for $motivation: $description\n";
say Dumper( \@choice );

foreach my $step (@choice) {
  say $step;
  $generated_subs{$step}->() if $step =~ /^\w/;
}

sub randomly_choose {
  my $step          = shift;
  my @possibilities = @$step;
  my $choice        = $possibilities[ rand @possibilities ];
  my $description   = $choice->{description};
  my @choice        = @{ $choice->{sequence} };
  return ( $description, @choice );
}

sub validate {
  my ( $actions, $motivations ) = @_;

  _validate( 'action',     $actions, $actions );
  _validate( 'motivation', $actions, $motivations );
}

sub _validate {
  my ( $type, $actions, $metadata ) = @_;

  while ( my ( $key, $options ) = each %$metadata ) {
    my $index = 0;
    foreach my $option(@$options) {
      my $sequence = $option->{sequence};
      foreach my $step (@$sequence) {
        next if $step =~ /^>/;
        unless ( exists $actions->{$step} ) {
          die "Unknown $type for $key\[$index]: $step";
        }
      }
      $index++;
    }
  }
}

__END__

=head1 NAME

quest.pl - Random quest generator

=head1 DESCRIPTION

This is based on the paper "A Prototype Quest Generator Based on a Structural 
Analysis of Quests from Four MMORPGs". You can find this paper at http://larc.unt.edu/techreports/LARC-2011-02.pdf
If you do not read that paper, the generated quest may not make much sense.

The authors analyzed 3,000 quests from four RPGs and found that quests
generally could follow a predictable structure, though this structure was
often very complex.

The idea is to randomly generate quests based on multiple motivations. This is
a proof of concept for a game the author is writing. It's possible that I'll
expand this significantly for my personal work, or perhaps I'll use the
general information to inspiration instead of adhering too closely to the
output.

The primary quest motivations involved in the research were:

=over 4

=item * knowledge

=item * comfort

=item * reputation

=item * serenity

=item * protection

=item * conquest

=item * wealth

=item * ability

=item * equipment

=back

=head1 Usage:

 quest.pl --depth $depth

If C<$depth> is not supplied or is less than 1, it defaults to 3. Note that
this is actually the I<maximum> depth allowed. For larger depth values, you'll
probably get a lower depth.

It's also important to note that this is just a proof of concept and we don't
actually try to generate proper names for anything, such as NPCs, objects,
places, and so on. Instead, we generate the structure of a quest. Here's a
sample output for a quest where we requested a depth of 8.

    Generating a quest for serenity: Rescue captured NPC

    ['goto','>damage','>escort','goto','>report']
    goto
        [Find out where to go and go there] ['learn','>goto']
        learn
            [Go someplace, get something, and read what is written on it] ['goto','get','>read']
            goto
                [Find out where to go and go there] ['learn','>goto']
                learn
                    [Go someplace, get something, and read what is written on it] ['goto','get','>read']
                    goto
                        [Just wander around and look] ['>explore']
                        >explore
                    get
                        [Go someplace and pick something up that’s lying around there] ['goto','>gather']
                        goto
                            [Find out where to go and go there] ['learn','>goto']
                            learn
                                [Go someplace, get something, and read what is written on it] ['goto','get','>read']
                                goto
                                    [Find out where to go and go there] ['>goto']
                                    >goto
                                get
                                    [Go someplace and pick something up that’s lying around there] ['>gather']
                                    >gather
                                >read
                            >goto
                        >gather
                    >read
                >goto
            get
                [Steal it from somebody] ['steal']
                steal
                    [Go someplace, sneak up on somebody, and take something] ['goto','>stealth','>take']
                    goto
                        [Find out where to go and go there] ['learn','>goto']
                        learn
                            [Go someplace, get something, and read what is written on it] ['goto','get','>read']
                            goto
                                [Find out where to go and go there] ['learn','>goto']
                                learn
                                    [Go someplace, get something, and read what is written on it] ['>read']
                                    >read
                                >goto
                            get
                                [Go someplace and pick something up that’s lying around there] ['goto','>gather']
                                goto
                                    [Just wander around and look] ['>explore']
                                    >explore
                                >gather
                            >read
                        >goto
                    >stealth
                    >take
            >read
        >goto
    >damage
    >escort
    goto
        [Just wander around and look] ['>explore']
        >explore
    >report
