package Reversi;
 
use v5.10.0;
use strict;
use warnings;
use Carp;
use List::Util qw/none all sum/;
use feature 'say';

my $default_board_len = 8;

sub default_board_len {
    croak "Board length should be an even integer only.\n" if $_[1] % 2 != 0;
    $default_board_len = $_[1];
    return $default_board_len;
}

sub new {
    my ($class) = @_;
    my ($len) = $_[1] || $default_board_len;
    croak "Board length should be an even integer only.\n" if $len % 2 != 0;
    my $board;
    for my $alpb (0..$len-1) {
        for my $num (0..$len-1) {
            $board->[$alpb][$num] = '.';
        }
    }
    $board->[$len / 2][$len / 2] = 'o';
    $board->[$len / 2 - 1][$len / 2 - 1] = 'o';
    $board->[$len / 2 - 1][$len / 2] = 'x';
    $board->[$len / 2][$len / 2 - 1] = 'x';
    bless {
        _length => $len,
        _bd => $board,
        _game_over => 0,
    }, $class;
} 

sub bd {
    $_[0]->{_bd};
}

sub wpieces {
    my $len = $_[0]->len;
    my $player = $_[1];
    return grep {$_[1] eq $_[0]->bd->[$_ / $len][$_ % $len]} 
            (0..$len*$len-1)
}


sub len {
    $_[0]->{_length};
}

sub game_over {
    my $len = $_[0]->len;
    $_[0]->{_game_over} = 0;
    if ( $_[0]->wpieces('.') == 0 ) {
        $_[0]->{_game_over} = 1;
    }
    elsif (( none 
          {sum($_[0]->available_dir('x', [int $_ / $len, $_ % $len])->@*) != 0}
          (0..$len*$len-1) ) &&
        ( none 
          {sum($_[0]->available_dir('o', [int $_ / $len, $_ % $len])->@*) != 0}
          (0..$len*$len-1) )) {
        $_[0]->{_game_over} = 1;
    }
    elsif ( $_[0]->wpieces('x') == 0 || $_[0]->wpieces('o') == 0) {
        $_[0]->{_game_over} = 1;
    }
    return $_[0]->{_game_over};
}

sub board {
    my $display = "";
    my $len = $_[0]->length;
    for my $num (0..$len-1) {
        for my $alpb (0..$len-1) {
            $display .= $_[0]->bd->[$num][$alpb]." ";
        }
        $display .= "\n";
    }
    return $display;
}

sub show {
    say $_[0]->board;
}

sub view {
    my $len = $_[0]->len;
    my $display = "   ".join " ", ('a'..chr(ord('a')+$len-1) );
    $display .= "\n";
    for my $num (0..$len-1) {
        $display .= sprintf("%2d", $num+1)." ";
        for my $alpb (0..$len-1) {
            $display .= $_[0]->bd->[$num][$alpb]." ";
        }
        $display .= "\n";
    }
    say $display;
}


sub _make_move {
    my $player = $_[1];
    my $alt_player = $_[1] eq 'x' ? 'o' : 'x';
    my $position = $_[2];
    my $len = $_[0]->len;
    my ($e, $w) = @_[3..4];
    my ($s, $n) = @_[5..6];
    my ($se, $nw) = @_[7..8];
    my ($sw, $ne) = @_[9..10];
    if ($e || $w) {
        my $segmnt = join "", $_[0]->bd->[$position->[0]]->@*;
        $_[0]->bd->[$position->[0]]->@* = split "", $_[0]->modify($segmnt, $player, $position->[1], $e, $w);
    }
    if ($s || $n) {
        my $segmnt = join "", map {$_[0]->bd->[$_][$position->[1]]} (0..$len-1);
        my @arr = split "", $_[0]->modify($segmnt, $player, $position->[0], $s, $n);
        $_[0]->bd->[$_][$position->[1]] = $arr[$_] for (0..$len-1);
    }
    if ($se || $nw) {
        my $diff = $position->[1]-$position->[0];
        my ($startx, $starty) = $diff >= 0 ? (0, $diff) : (abs($diff), 0);
        my $segmnt = join "", map {$_[0]->bd->[$_+$startx][$_+$starty]} (0..$len-1-abs($diff));
        my @arr = split "", $_[0]->modify($segmnt, $player, $diff>=0? $position->[0]: $position->[1], $se, $nw); 
        $_[0]->bd->[$_+$startx][$_+$starty] = $arr[$_] for (0..$len-1-abs($diff));
    }
    if ($ne || $sw) {
        my $sum = $position->[1]+$position->[0];
        my ($startx, $starty) = $sum <= 5 ? ($sum, 0) : (5, $sum-5);
        my $segmnt = join "", map {$_[0]->bd->[$startx-$_][$starty+$_]} (0..$len-1-abs(5-$sum));
        my @arr = split "", $_[0]->modify($segmnt, $player, 5>=$sum? $position->[1]: 5-$position->[0] , $sw, $ne);
        $_[0]->bd->[$startx-$_][$starty+$_] = $arr[$_] for (0..$len-1-abs(5-$sum));
    }
}

sub modify {
    my $segmnt = $_[1];
    my $player = $_[2];
    my $alt_player = $_[2] eq 'x' ? 'o' : 'x';
    my $pos = $_[3];
    my $r = $_[4];
    my $l = $_[5];
    my $len = length $segmnt;
    my @arr = split "", $segmnt;
    if ($r) {
        my $j = index($segmnt, $player, $pos+2 );
        $arr[$_] = $player for ($pos .. $j-1);
    }
    if ($l) {
        my $rsegmnt = scalar reverse $segmnt;
        my $rpos = $len - $pos - 1;
        my $j = $len - index($rsegmnt, $player, $rpos+2 ) - 1;
        $arr[$_] = $player for ($j+1 .. $pos); 
    }
    return join "", @arr;
}


sub available_dir {
    my $player = $_[1];
    my $alt = $_[1] eq 'x' ? 'o' : 'x';
    my $position = $_[2];
    my $len = $_[0]->len;
    my $num_pos = $position->[0];
    my $alp_pos = $position->[1];
    return [0,0,0,0,0,0,0,0] if $_[0]->bd->[$num_pos][$alp_pos] ne '.';
    my $hori = join "", $_[0]->bd->[$num_pos]->@*;
    my $vert = join "", map {$_[0]->bd->[$_][$alp_pos]} (0..$len-1);
    my $diff = $alp_pos-$num_pos;
    my ($astartx, $astarty) = $diff >= 0 ? (0, $diff) : (abs($diff), 0);
    my $diag = join "", map {$_[0]->bd->[$_+$astartx][$_+$astarty]} (0..$len-1-abs($diff));
    my $d_pos = $diff >= 0 ? $num_pos : $alp_pos;
    my $sum = $alp_pos+$num_pos;
    my ($startx, $starty) = $sum <= 5 ? ($sum, 0) : (5, $sum-5);
    my $andi = join "", map {$_[0]->bd->[$startx-$_][$starty+$_]} (0..$len-1-abs(5-$sum));
    my $a_pos = 5 >= $sum ? $alp_pos : 5-$num_pos;
    return [ 
        substr($hori,$alp_pos+1) =~ /^$alt+$player/ ? 1 : 0,
        substr($hori,0,$alp_pos) =~ /$player$alt+$/ ? 1 : 0, 
        substr($vert,$num_pos+1) =~ /^$alt+$player/ ? 1 : 0,
        substr($vert,0,$num_pos) =~ /$player$alt+$/ ? 1 : 0, 
        substr($diag,$d_pos+1) =~ /^$alt+$player/ ? 1 : 0,
        substr($diag,0,$d_pos) =~ /$player$alt+$/ ? 1 : 0, 
        substr($andi,$a_pos+1) =~ /^$alt+$player/ ? 1 : 0,
        substr($andi,0,$a_pos) =~ /$player$alt+$/ ? 1 : 0, 
    ]
}

sub make_move {
    my $player = $_[1];
    my $position = $_[2];
    if ($_[0]->bd->[$position->[0]][$position->[1]] ne '.') {
        croak "Here already occupied!\n"; 
        return 0;
    }
    my @dir = $_[0]->available_dir($player, $position)->@*;
    if (none {$_ == 1} @dir) {
        croak "Cannot move here!\n";
        return 0;
    }
    $_[0]->_make_move($player, $position, @dir);
    return 1;
}


sub bd2str {
    croak "Method only for 6x6 board!\n" if $_[0]->len != 6;
    my $len = $_[0]->len;
    my @abc = ('0'..'9', 'a'..'z');
    my $ans = "B";
    for (0..35) {
        $ans .= $abc[$_] if $_[0]->bd->[int $_ / $len][$_ % $len] eq 'x';
    }
    $ans .= "W";
    for (0..35) {
        $ans .= $abc[$_] if $_[0]->bd->[int $_ / $len][$_ % $len] eq 'o';
    }
    return $ans;
}

sub available_moves {
    my $player = $_[1];
    my $len = $_[0]->len;
    my @init_arr = grep {sum($_[0]->available_dir(
            $player, [int $_ / $len, $_ % $len]
          )->@*) != 0} (0..$len*$len-1);
    return [map { [ int $_ / $len, $_ % $len ] } @init_arr];
}

sub posit {
    my $p = $_[1];
    return chr(ord('a')+$p->[1]) . (1+$p->[0]);
}

1;
