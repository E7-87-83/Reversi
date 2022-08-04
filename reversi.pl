{

    package Reversi;
     
    use v5.10.0;
    use strict;
    use warnings;
    use Carp;
    use feature 'say';

    my $default_board_len = 8;

    sub default_board_len {
        croak "Board length should be an even integer only.\n" if $_[1] % 2 != 0;
        $default_board_len = $_[1] || $default_board_len;
        return $default_board_len;
    }

    sub new {
        my ($class) = @_;
        my ($len) = $_[1] || default_board_len();
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
        }, $class;
    } 

    sub bd {
        $_[0]->{_bd};
    }

    sub length {
        $_[0]->{_length};
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
        my $len = $_[0]->length;
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


    sub make_move {
        my $player = $_[1];
        my $alt_player = $_[1] eq 'x' ? 'o' : 'x';
        my $position = $_[2];
        my $len = $_[0]->length;
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
            my @arr = split "", $_[0]->modify($segmnt, $player, 5>=$sum? $position->[1]: (5-$position->[0]) , $sw, $ne);
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


    # todo: available_nxt


}

use v5.30.0;
use warnings;
my $hello = Reversi->new(6);
say $hello->length;
say $hello->bd->[3][3];
$hello->view;
$hello->make_move('x', [3,4], 0, 1, 0, 0);  #e4
$hello->view;
$hello->make_move('o', [4,2], 0, 0, 0, 1);  #c5
$hello->view;
$hello->make_move('x', [3,1], 1, 0, 0, 0);  #b4
$hello->view;
$hello->make_move('o', [4,4], 0, 0, 0, 0, 0, 1);  #e5
$hello->view;
$hello->make_move('x', [4,3], 0, 0, 0, 1, 0, 0);  #d5
$hello->view;
$hello->make_move('o', [2,4], 0, 1, 1, 0, 0, 0, 0 ,1);  #e3
$hello->view;
$hello->make_move('x', [1,3], 0, 0, 1, 0, 0, 0, 0 ,1);  #d2
$hello->view;
$hello->make_move('o', [1,2], 0, 0, 1, 0, 1, 0, 0 ,0);  #c2
$hello->view;
