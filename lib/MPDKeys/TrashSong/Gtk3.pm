package MPDKeys::TrashSong::Gtk3;
use 5.016;

use utf8;
use open ':std', ':encoding(UTF-8)';

use strict;
use warnings;
use autodie;
use Carp;

use Gtk3 ('-init');

use parent ('MPDKeys::TrashSong');

sub run {
    my ($self, $msg) = @_;

    my $button = {};
    my $button_keys = {};

    foreach ('cancel', 'trash') {
        my $label = Gtk3::Label->new_with_mnemonic(
            $self->{gettext}->{button}->{$_}
        );
        $button->{$_} = Gtk3::Button->new;
        $button->{$_}->add($label);
        $button_keys->{$_} = $label->get_mnemonic_keyval;

        unless (exists $button_keys->{$_}) {
            carp sprintf(
                $self->{warn},
                "Button " . $_ . " without proper mnemonic"
            );
        }
    }


    my
    $headerbar = Gtk3::HeaderBar->new;
    $headerbar->set_title($self->{gettext}->{my}->{question});
    $headerbar->set_subtitle($self->{gettext}->{my}->{title});
    $headerbar->set_show_close_button(0);
    $headerbar->pack_start($button->{cancel});
    $headerbar->pack_end($button->{trash});


    my
    $grid = Gtk3::Grid->new;
    $grid->set_column_spacing(10);
    $grid->set_row_spacing(5);

    my $row = 0;
    
    foreach (@{$self->{show_info_from}}) {
        $row++;

        my
        $label_l = Gtk3::Label->new;
        $label_l->set_markup(
            sprintf(
                "<b>%s:</b>",
                $self->{gettext}->{mpd}->{$_} || $_
            )
        );
        $label_l->set_halign('GTK_ALIGN_START');
        $label_l->set_valign('GTK_ALIGN_START');

        my
        $label_r = Gtk3::Label->new(
            $self->{song}->{$_} || $self->{gettext}->{mpd}->{'<empty>'}
        );
        $label_r->set_hexpand(1);
        $label_r->set_halign('GTK_ALIGN_START');
        $label_r->set_valign('GTK_ALIGN_START');
        $label_r->set_selectable(1);
        $label_r->set_line_wrap(1);

        # grid->attach(widget, left, top, width, height)
        $grid->attach($label_l, 1, $row, 1, 1);
        $grid->attach($label_r, 2, $row, 1, 1);
    }


    my
    $window = Gtk3::Window->new('toplevel');
    $window->set_skip_taskbar_hint(0);
    $window->set_icon_name('edittrash');
    $window->set_keep_above(1);
    $window->set_titlebar($headerbar);
    $window->set_default_size(500, 0);
    $window->set_position('GTK_WIN_POS_CENTER');
    $window->set_border_width(10);
    $window->add($grid);
    $window->show_all;


    # compiled regexp
    my $re = {
        ctrl_super_shift => qr/(control-mask|super-mask|shift-mask)/us,
        alt => qr/mod1-mask/us
    };


    # callbacks
    $window->signal_connect(
        'key_press_event',
        sub { $self->gtk3_cb_key_event(@_, $re, $button_keys) }
    );
    $button->{cancel}->signal_connect(
        'clicked',
        sub{ $self->gtk3_cb_quit(@_) }
    );

    $button->{trash}->signal_connect(
        'clicked',
        sub{ $self->gtk3_cb_trash_song(@_) }
    );


    Gtk3->main;

    $window->destroy;

    return 1
}

sub gtk3_cb_key_event {
    my ($self, $window, $key, $re, $button_key) = @_;

    unless ($key->state =~ /$re->{ctrl_super_shift}/) {
        if ($key->state =~ /$re->{alt}/) {
            if (
                defined $button_key->{cancel}
                    and ($key->keyval eq $button_key->{cancel} )
            ) {
                $self->gtk3_cb_quit;
            } elsif (
                defined $button_key->{trash}
                    and ($key->keyval eq $button_key->{trash} )
            ) {
                $self->gtk3_cb_trash_song;
            }

        } else {
            if ($key->keyval eq Gtk3::Gdk::KEY_Escape) {
                $self->gtk3_cb_quit;
            }
        }
    }

    return 1
}

sub gtk3_cb_quit {
    my $self = shift;
    Gtk3::main_quit;
    return 1;
}

sub gtk3_cb_trash_song {
    my $self = shift;
    $self->trash_song;
    $self->gtk3_cb_quit;
    return 1;
}

1;

__END__
