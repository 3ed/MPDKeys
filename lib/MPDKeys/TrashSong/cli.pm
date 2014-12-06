package MPDKeys::TrashSong::cli;
use 5.016;

use utf8;
use open ':std', ':encoding(UTF-8)';

use strict;
use warnings;
use autodie;

use parent ('MPDKeys::TrashSong');

sub run {
    my $self = shift;

    # Get max horizontal width from strings in first column of table
    my $width = 0;

    foreach (
        map { length }
        map { $self->{gettext}->{mpd}->{$_} || $_ }
        @{$self->{show_info_from}}
        # ^^ Schwartzian transform - read backwards
    ) {
        $width = $_ if ($_ > $width);
    }

    # Write table with song informations
    foreach (@{$self->{show_info_from}}) {
        printf(
            "\e[0;32;1m% ${width}s \e[0;1m:\e[0m %s\n",
            $self->{gettext}->{mpd}->{$_} || $_,
            $self->{song}->{$_} || $self->{gettext}->{mpd}->{'<empty>'}
        )
    }

    # Ask question
    printf(
        "\n\e[34;1m::\e[0;1m %s\e[0m [%s] ",
        $self->{gettext}->{my}->{question},
        $self->{gettext}->{my}->{yesno}
    );

    # Get key and decide
    my $ans = lc readline STDIN;
    my $key = lc substr $self->{gettext}->{my}->{yesno}, 0, 1;

    return $self->trash_song if $ans =~ /^$key/;

    return 1
}
1;
