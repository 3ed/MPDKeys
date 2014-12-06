MPDKeys
=======

mpd multimedia keys tool (in future will be tools i hope)

Using gettext, modern good looking gnome3 windows with headerbar.

# Translations
- Polish (100%)

# Dependiences
- Locale::TextDomain
- Gtk3
- File::Trash::FreeDesktop
- Net::MPD

# What done or not
## Done
- MPDKeys::TrashSong - Remove that song simple by pressing key and click on "Move to _trash" or press "y" and "enter" in cli version.
  - Gtk3: bin/mpdkeys-trashsong-gui (use MPDKeys::TrashSong::Gtk3 with inheritance to MPDKeys::TrashSong)
  - cli: bin/mpdkeys-trashsong (use MPDKeys::TrashSong::cli with inheritance to MPDKeys::TrashSong)

## Done but not ready or simple, not merged
- MPDKeys::DO - notifications for key actions like: next, back, seek

## Any suggestions?
- Maybe there is something that I will like, but your idea, not main.
