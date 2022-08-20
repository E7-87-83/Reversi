require "./Reversi.pm";

use v5.30.0;
use warnings;

my $t_game = Reversi->new(6);

my $side = 'x';
for my $t (1..32) {
    my @moves = $t_game->available_moves($side)->@*;
    if (scalar @moves == 0) {
        $side = $side eq 'x' ? 'o' : 'x'; 
        @moves = $t_game->available_moves($side)->@*;
    }
    my $m = $moves[int rand(scalar @moves)];
    $t_game->make_move($side, $m);
    $t_game->view;
    say "$t $side ", $t_game->posit($m), " ", $t_game->wpieces('x') - $t_game->wpieces('o');
    $side = $side eq 'x' ? 'o' : 'x'; # switch side
    last if $t_game->game_over;
}
