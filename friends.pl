#! env perl
use Modern::Perl;
use Text::CSV_XS;
no warnings "experimental";
no warnings "uninitialized";

my $people;
my $votes;
my $friendship;

my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });

open my $fh, "<:encoding(utf8)", "people.csv" or die $!;
<$fh>;  # skip header
while (my $row = $csv->getline($fh)) {
  # people_id -> name
  $people->{$row->[0]} = {name => $row->[1]};
}

open $fh, "<:encoding(utf8)", "votes.csv" or die $!;
<$fh>;  # skip header
while (my $row = $csv->getline($fh)) {
  # people_id -> roll_call_id = vote_desc
  next unless ($row->[3] =~ /(Yea|Nay)/);
  $votes->{$row->[1]}->{$row->[0]} = $row->[3];
}

foreach my $person (keys %$people) {
  # next unless ($person == 18370);  # Justin Wayne
  # next unless ($person == 16611);   # Adam Morfeld
  foreach my $other_person (keys %$people) {
    next if ($person == $other_person); # ignore themselves
    # next unless ($other_person == 18640); # Lynne Walz
    foreach my $roll_call_id (keys %{$votes->{$other_person}}) {
      my $person_vote = $votes->{$person      }->{$roll_call_id};
      my $other_vote  = $votes->{$other_person}->{$roll_call_id};
      next unless ($person_vote && $other_vote);
      if ($person_vote eq $other_vote) {
        $friendship->{$person}->{$other_person}->{agree} += 1;
        # say "$roll_call_id: $person $person_vote $other_person $other_vote +1";
        # say "$roll_call_id: $person $person_vote $other_person $other_vote +1 = " . $friendship->{$person}->{$other_person};
      } else {
        $friendship->{$person}->{$other_person}->{disagree} += 1;
        # say "$roll_call_id: $person $person_vote $other_person $other_vote -1";
        # say "$roll_call_id: $person $person_vote $other_person $other_vote -1 = " . $friendship->{$person}->{$other_person};
      }
    }
  }
}

my %printed_already;
say "agree,disagree,name,name";
foreach my $person (keys %$friendship) {
  # next unless ($person == 18370);  # Justin Wayne
  # say $people->{$person}->{name};
  my $x = $friendship->{$person};
  foreach my $other_person (sort { $x->{$b} <=> $x->{$a} } keys %$x) {
    next if ($printed_already{ join ".", sort $person, $other_person });
    #printf("%3s %3s %s <-> %s\n",
    #  $x->{$other_person}->{agree},
    #  $x->{$other_person}->{disagree},
    #  $people->{$person}->{name},
    #  $people->{$other_person}->{name},
    #);
    say join ",", 
      $x->{$other_person}->{agree},
      $x->{$other_person}->{disagree},
      $people->{$person}->{name},
      $people->{$other_person}->{name},
    ;
    $printed_already{ join ".", sort $person, $other_person } = 1;
  }
}
# ./friends.pl | sort -n -r


__END__

# Text output -- strongest friends to weakest
my %printed_already;
foreach my $person (keys %$friendship) {
  # next unless ($person == 18370);  # Justin Wayne
  # say $people->{$person}->{name};
  my $x = $friendship->{$person};
  foreach my $other_person (sort { $x->{$b} <=> $x->{$a} } keys %$x) {
    next if ($printed_already{ join ".", sort $person, $other_person });
    printf("%s %s <-> %s\n",
      $x->{$other_person},
      $people->{$person}->{name},
      $people->{$other_person}->{name},
    );
    $printed_already{ join ".", sort $person, $other_person } = 1;
  }
}
# ./friends.pl | sort -n -r


# Maybe we want a chord diagram?    ooof... probably not?  http://jays.net/tmp/friends.html
# https://www.amcharts.com/demos/chord-diagram/
foreach my $person (keys %$friendship) {
  # next unless ($person == 18370);  # Justin Wayne
  # say $people->{$person}->{name};
  my $x = $friendship->{$person};
  foreach my $other_person (sort { $x->{$b} <=> $x->{$a} } keys %$x) {
    printf("  { source: '%s', target: '%s', value: %s },\n",
      $people->{$person}->{name},
      $people->{$other_person}->{name},
      $x->{$other_person},
    );
  }
}


