require "./Reversi.pm";

use v5.30.0;
use warnings;
my $hello = Reversi->new(6);
say $hello->len;
say $hello->bd->[3][3];
$hello->view;
$hello->make_move('x', [3,4]);
$hello->view;

$hello->make_move('o', [4,2]);
$hello->view;

$hello->make_move('x', [3,1]);
$hello->view;

$hello->make_move('o', [4,4]);
$hello->view;
$hello->make_move('x', [4,3]);
$hello->view;
$hello->make_move('o', [2,4]);
$hello->view;
$hello->make_move('x', [1,3]);
$hello->view;
$hello->make_move('o', [1,2]);
$hello->view;
