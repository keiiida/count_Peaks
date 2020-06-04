#!/usr/bin/perl
use strict;

if(@ARGV != 3){
   print "search_overlap.pl primary.bed(Base) secondary.bed(Comp) threshold_for_overlap(0-1)\n";
   exit(0);
}
my $TH = $ARGV[2];

open(F,$ARGV[0]) || die "Cannot open the file; $ARGV[0]\n";
my @lines0B = (); #BED Format
@lines0B = <F>;
chomp(@lines0B);
close(F);
my @lines0D = @{&bed2dat(\@lines0B)}; #Convert to Dat Format

open(F,$ARGV[1]) || die "Cannot open the file; $ARGV[1]\n";
my @lines1B = (); #BED Format
@lines1B = <F>;
chomp(@lines1B);
close(F);
my @lines1D = @{&bed2dat(\@lines1B)}; #Convert to Dat Format

my %line_box1 = ();
my %mem = ();
foreach (@lines1D){
   my @tmp = ();
   @tmp = split(/\t/,$_);
   push(@{${$line_box1{$tmp[2]}}{$tmp[1]}},$_);
   if($mem{$tmp[0]} ne ""){
      print "ERROR! ID: $tmp[0] is dupplicated! ID Must be unique.\n";
      exit(0);
   }
   $mem{$tmp[0]} = $_;
}

my %line_box0 = ();
foreach (@lines0D){
   my @tmp = ();
   @tmp = split(/\t/,$_);
   push(@{${$line_box0{$tmp[2]}}{$tmp[1]}},$_);
}

foreach my $chr (keys %line_box1){
   foreach my $dir (keys %{$line_box1{$chr}}){
      @{${$line_box1{$chr}}{$dir}} = sort {(split(/\t/,$a))[3] <=> (split(/\t/,$b))[3]} @{${$line_box1{$chr}}{$dir}};
      @{${$line_box0{$chr}}{$dir}} = sort {(split(/\t/,$a))[3] <=> (split(/\t/,$b))[3]} @{${$line_box0{$chr}}{$dir}};
   }
}

printf "#ID1\tIDs2\tNum_of_Overlapped_ID2\n";
my $ll_sum = 0;
foreach my $chr (keys %line_box1){
   foreach my $dir (keys %{$line_box1{$chr}}){
      my $pre = 0;
      foreach my $line00 (@{${$line_box0{$chr}}{$dir}} ){
         $line00 =~ s/[\r\n]+//g;
         my $line0 = $line00;
         my @tmp = ();
         @tmp = split(/\t/,$line00);
         my $id = $tmp[0];
        
         my $start = $tmp[3];
         my $end = $tmp[4];
         my $len = $end - $start;
         if($len < 0){
            $len = $len * (-1);
         }
         $len = $len + 1;
         my @box = ();
         my @box2 = ();
         my @box3 = ();
         my $pre_flag=0;
         for(my $i=$pre;$i<@{${$line_box1{$chr}}{$dir}};$i++){
            my $line = ${${$line_box1{$chr}}{$dir}}[$i];
            my @tmp = ();
            @tmp = split(/\t/,$line);
            #if($tmp[3] >= $start && $tmp[4] <= $end){ #For Comple Including }
            if($tmp[4] >= $start && $tmp[3] <= $end){ #OVERLAP
               if($pre_flag==0){
                  $pre_flag=1;
                  $pre = $i-1;
                  if($pre < 0){
                     $pre = 0;
                  }
               }
               push(@box,$tmp[0]);
               my @tmp2 = (); 
               @tmp2 = sort {$a <=> $b} ($tmp[3],$tmp[4],$start,$end);
               my $len2 = $tmp2[2] - $tmp2[1] + 1;
               push(@box2,$len2);

               my $len3 = $tmp[4] - $tmp[3];
               if($len3 < 0){
                  $len3 = $len3 * (-1);
               }
               $len3 = $len3 + 1;
               push(@box3,$len3);
            }
            if($tmp[3] > $end){
               last;
            }
         }
      
         my @boxOUT = ();
         for(my $i=0;$i<@box;$i++){
            if($box2[$i] / $len < $TH && $box2[$i] / $box3[$i] < $TH){
               next;
            }
            push(@boxOUT,$box[$i]);
         }
         if(@boxOUT > 0){
            my $n = @boxOUT;
            printf "%s\t%s\t%d\n",$id,join(",",@boxOUT),$n;
         }else{
            printf "%s\t-\t0\n",$id;
         }
      
      }
   }
}

#//main

sub bed2dat{
   my @lines = @{$_[0]};
   my @out = ();
   foreach (@lines){
      my @tmp = ();
      @tmp = split(/\t/,$_);
      my $chr = $tmp[0];
      my $id = $tmp[3];
      my $dir0 = $tmp[5];
      my $dir = $dir0;
      $dir =~ tr/+-/10/;
      my $start = $tmp[1] + 1;
      my @tmp2 = ();
      @tmp2 = split(/,/,$tmp[10]);
      my @tmp3 = ();
      @tmp3 = split(/,/,$tmp[11]);
      my @exons = ();
      for(my $i=0;$i<@tmp2;$i++){
         if($tmp2[$i] eq ""){
            next;
         }
         push(@exons,sprintf("%s..%s",$start+$tmp3[$i],$start+$tmp3[$i]+$tmp2[$i]-1));
      }
      my $end = (split(/\.\./,$exons[-1]))[1];
      if($dir eq '.'){
         next;
      }
      my $ll = sprintf "%s\t%s\t%s\t%s\t%s\t%s",$id,$dir,$chr,$start,$end,join(",",@exons);
      push(@out,$ll);
   }
   return(\@out);
}
