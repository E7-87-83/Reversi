require "./Reversi.pm";
use Data::Dump qw/pp/;

use v5.30.0;

my $hello = Reversi->new(6);
$hello->view;
say $hello->bd2str;
say pp $hello->available_moves('x');
