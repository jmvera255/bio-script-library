#! /usr/bin/perl

use strict;
use DateTime;
my(%logs, %submit_dates, %term_dates);

my @events = ("submit", "start_trans_in", "finish_trans_in", "execute", 
              "start_trans_out", "finish_trans_out", "terminate");

my $log_file = shift;
open(LOG, "< $log_file") || die "cannot open log file $log_file!";
while(my $line = <LOG>){
  chomp($line);
  if($line =~ /^0/){
    my($job_id, $date, $time);
    $line =~ /^\d\d\d \(([0-9]{7,8}.[0-9]{3,5})\.\d\d\d\) (\d\d\d\d-\d\d-\d\d) (\d\d:\d\d:\d\d)/;
    $job_id = $1;
    $date = $2;
    $time = $3;
    my $epoch_time = getEpoch($date, $time);
    if($line =~ /Job submitted from host/){
      #$logs{$job_id}{$events[0]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[0]}}, join(" ", $date, $time), $epoch_time);
    }
    elsif($line =~ /Started transferring input files/){
      #$logs{$job_id}{$events[1]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[1]}}, join(" ", $date, $time), $epoch_time);
    }
    elsif($line =~ /Finished transferring input files/){
      #$logs{$job_id}{$events[2]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[2]}}, join(" ", $date, $time), $epoch_time);
    }
    elsif($line =~ /Job executing on host/){
      #$logs{$job_id}{$events[3]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[3]}}, join(" ", $date, $time), $epoch_time);
    }
    elsif($line =~ /Started transferring output files/){
      #$logs{$job_id}{$events[4]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[4]}}, join(" ", $date, $time), $epoch_time);
    }
    elsif($line =~ /Finished transferring output files/){
      #$logs{$job_id}{$events[5]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[5]}}, join(" ", $date, $time), $epoch_time);
    }
    elsif($line =~ /Job terminated/){
      #$logs{$job_id}{$events[6]} = join(" ", $date, $time);
      push(@{$logs{$job_id}{$events[6]}}, join(" ", $date, $time), $epoch_time);
    }
  }
}

# print results to stdout
# @events = ("submit", "start_trans_in", "finish_trans_in", "execute", 
#              "start_trans_out", "finish_trans_out", "terminate");

print "Job\t" . join("\t", @events, "time_idle", "runtime") . "\n";
foreach my $job (sort {$a <=> $b} keys %logs){
  print "$job";
  foreach my $e (@events){
    print "\t$logs{$job}{$e}[1]"
  }

  my $idle = $logs{$job}{$events[1]}[1] - $logs{$job}{$events[0]}[1];
  my $run = $logs{$job}{$events[4]}[1] - $logs{$job}{$events[3]}[1];
  print "\t$idle\t$run";
  print "\n";
}

# subroutines
sub getEpoch {
  my @date = split("-", $_[0]);
  my @time = split(":", $_[1]);
 
  my $dt = DateTime->new(
    year       => $date[0],
    month      => $date[1],
    day        => $date[2],
    hour       => $time[0],
    minute     => $time[1],
    second     => $time[2],
    time_zone  => 'America/Chicago');

  my $epoch_time = $dt->epoch;
  return($epoch_time);
}
