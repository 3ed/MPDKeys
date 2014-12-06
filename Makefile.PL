#! /usr/bin/perl
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		    => 'MPDKeys',
    VERSION_FROM	=> 'lib/MPDKeys/TrashSong.pm',
    PREREQ_PM	    => {
        "Locale::TextDomain" => 0,
        "Gtk3" => 0,
        "File::Trash::FreeDesktop" => 0,
        "Net::MPD" => 0
    },
	EXE_FILES		=> [
        'bin/mpdkeys-trashsong',
        'bin/mpdkeys-trashsong-gui',
    ],
	AUTHOR          => '3ED <krzysztof1987@gmail.com>',
    ABSTRACT        => 'mpd multimedia keys tool',
    LICENSE         => 'gpl_2',
);
