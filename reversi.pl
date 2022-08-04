{

    package Reversi;
     
    use v5.10.0;
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
        croak "Board length should be an even integer only.\n" if $board_len % 2 != 0;
        my $board;
        for my $alpb (0..$len-1) {
            for $num (0..$len-1) {
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
            for $alpb (0..$len-1) {
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
            for $alpb (0..$len-1) {
                $display .= $_[0]->bd->[$num][$alpb]." ";
            }
            $display .= "\n";
        }
        say $display;
    }


    sub make_move {
        my $player = $_[1];
        my $alt_player = $_[1] == 'x' ? 'o' : 'x';
        my $position = $_[2];
        my $len = $_[0]->length;
        my ($e, $w) = @_[3..4];
        my ($s, $n) = @_[5..6];
        if ($e || $w) {
            my $segmnt = join "", $_[0]->bd->[$position->[0]]->@*;
            my @arr = split "", $segmnt;
            my $pos = $position->[1];
            if ($e) {
                my $j = index($segmnt, $player, $pos+2 );
                $arr[$_] = $player for ($pos .. $j-1);
            }
            if ($w) {
                my $rsegmnt = scalar reverse $segmnt;
                my $rpos = $len - $pos - 1;
                my $j = $len - index($rsegmnt, $player, $rpos+2 ) - 1;
                $arr[$_] = $player for ($j+1 .. $pos);  
            }
            $_[0]->bd->[$position->[0]]->@* = @arr;
        }
        if ($s || $n) {
            my $segmnt = join "", map {$_[0]->bd->[$_][$position->[1]]} (0..$len-1);
            my @arr = split "", $segmnt;
            my $pos = $position->[0];
            if ($s) {
                my $j = index($segmnt, $player, $pos+2 );
                $arr[$_] = $player for ($pos .. $j-1);
            }
            if ($n) {
                my $rsegmnt = scalar reverse $segmnt;
                my $rpos = $len - $pos - 1;
                my $j = $len - index($rsegmnt, $player, $rpos+2 ) - 1;
                $arr[$_] = $player for ($j+1 .. $pos);  
            }
            $_[0]->bd->[$_][$position->[1]] = $arr[$_] for (0..$len-1);
        }
        
    }


}

use v5.30.0;
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
