package MPDKeys::TrashSong;
use 5.016;
use version; our $VERSION = qv('v0.1');

use utf8;
use open ':std', ':encoding(UTF-8)';

use strict;
use warnings;
use autodie;
use Carp;

use Locale::TextDomain ('mpdkeys-trashsong');
use Locale::Messages ('bind_textdomain_filter', 'bind_textdomain_codeset', 'turn_utf_8_on');
BEGIN {
    bind_textdomain_filter 'mpdkeys-trashsong', \&turn_utf_8_on;
    bind_textdomain_codeset 'mpdkeys-trashsong', 'utf-8';
}

use Getopt::Long (':config', 'gnu_getopt');
use Net::MPD ();
use File::Trash::FreeDesktop ();
use IO::File ();

sub new {
    my ($class, @config) = @_;

    my $self = bless({}, $class);

    my $usage = sprintf(
        "%s %s (c) 3ED %s // LICENSE: GPL2 Artistic\n\n",
        "MPD Keys - Trash Song",
        "$VERSION",
        "2014"
    );

    $usage .= __<<EOF;
Usage:
  this_program [Options]

Options:
  -H=127.0.0.1:6600 | --host=127.0.0.1:6600
    [password\@][host][:port] - all options are optional

  -c=/etc/mpd.conf | --config=/etc/mpd.conf
    read this mpd config file to determine music_dir

  -d=/path/to/music_dir | --music_dir=/path/to/music_dir
    this is directory with music (implies disable option -c)

  -p=mpd/path | --mpd_path=mpd/path
    mpd path to specific file (not filesystem path)
EOF

    Getopt::Long::GetOptionsFromArray(\@config,
        'H|host=s'      => \$self->{host},
        'c|config=s'    => \$self->{config_file},
        'd|music_dir=s' => \$self->{music_dir},
        'p|mpd_path=s'  => \$self->{mpd_path},
        'h|help'        => sub { print $usage; exit 1 }
    );

    $self->init;

    return $self
}

sub init {
    my $self = shift;

    $self->{err}  = __"[Error] %s";
    $self->{err2} = __"[Error] %s: %s";
    $self->{warn} = __"[Warn] %s";

    $self->{gettext} = {
        my    => {
            title     => __"MPD Keys - Trash Song",
            question  => __"Move this song to trash?",
            yesno     => __"y/N",
        },
        button => {
            trash     => __"Move to _trash",
            cancel    => __"_Cancel"
        },
        mpd    => {
            Track     => __"Track",
            uri       => __"File",
            Title     => __"Title",
            Artist    => __"Artist",
            Album     => __"Album",
            "<empty>" => __"<empty>",
        }
    };

    $self->{show_info_from} = [
        'Artist', 'Title', 'Album', 'uri'
    ];

    croak sprintf( $$self{'err'}, __"MPD is not running" )
      unless $self->{mpd} = Net::MPD->connect( $self->{host} || undef );

    $self->{trash} = File::Trash::FreeDesktop->new;

    $self->{config_file} ||= '/etc/mpd.conf';
    $self->{music_dir}   ||= $self->get_music_dir;

    $self->get_mpd_song_info;

    return 1
}

sub trash_song {
    my ($self) = @_;

    croak sprintf(
        $self->{err2},
        $!,
        $self->{fs_file}
    ) unless -f $self->{fs_file};

    $self->move_song_to_trash;
    $self->mpd_update_mpd_path;

    return 1;
}

sub move_song_to_trash {
    my $self = shift;

    croak sprintf(
        $self->{err},
        __"Move file to trash failed"
    ) unless $self->{trash}->trash( $self->{fs_file} );

    return 1
}

sub mpd_update_mpd_path {
    my $self = shift;

    $self->{mpd}->update($self->{mpd_path});

    return 1
}

sub get_mpd_song_info {
    my ($self, $path) = @_;

    if (defined $self->{mpd_path}) {
        my $first_from_array =
            ($self->{mpd}->list_all_info($self->{mpd_path}))[0];

        croak sprintf(
            $self->{err},
            "mpd_path is not indexed"
        ) unless exists $first_from_array->{type};

        if ($first_from_array->{type} eq "file") {
            $self->{fs_file} = $self->{music_dir} . "/" . $self->{mpd_path};
            $self->{song}    = $first_from_array;
        } else {
            croak sprintf(
                $self->{err2},
                __"mpd_path is not a file",
                $self->{mpd_path}
            );
        }
    } else {
        my $info = $self->{mpd}->current_song;
        
        if (exists $info->{type}) {
            $self->{fs_file} = $self->{music_dir} . "/" . $info->{uri};
            $self->{song}    = $info;
        } else {
            croak sprintf(
                $self->{err},
                __"MPD stopped, none song currently set as active"
            );
        }
    }

    croak sprintf(
        $self->{err2},
        $!,
        $self->{fs_file}
    ) unless -e $self->{fs_file};

    return 1
}

sub get_music_dir {
    my $self = shift;
    my $OUT;

    my $fh = IO::File->new($self->{config_file}, 'r');

    croak sprintf(
        $self->{err},
        $!
    ) unless defined $fh;

    my $re_emptyhash = qr/^\s*#/us;
    my $re_music_dir = qr/music_directory\s+"(.*)"/us;

    while ( defined ($_ = readline $fh) ) {
        next       if /$re_emptyhash/;
        return $1  if /$re_music_dir/;
    }

    $! = 1;
    croak sprintf(
        $self->{err2},
        __"Can't locate music_directory option inside",
        $self->{config_file}
    );
}
1;

__END__
