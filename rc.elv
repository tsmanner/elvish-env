# Default rc.elv file which will pull and load the modules here
use epm
use os

epm:upgrade
epm:install &silent-if-installed=$true github.com/tsmanner/elvish-env

# If nix is installed, add it's paths.
if (os:exists /nix/var/nix/profiles/default/bin) {
  set paths = [(printf "%s/.nix-profile/bin" (get-env HOME)) /nix/var/nix/profiles/default/bin $@paths]
  set-env LOCALE_ARCHIVE (printf "%s/.nix-profile/lib/locale/locale-archive" (get-env HOME))
}

# If the user has a local bin, make that the first path.
if (os:exists (printf "%s/.local/bin" (get-env HOME))) {
  set paths = [(printf "%s/.local/bin" (get-env HOME)) $@paths]
}

use github.com/tsmanner/elvish-env/prompt
use github.com/tsmanner/elvish-env/git

fn ls {|@args| e:ls --color $@args}
fn l  {|@args| ls -al $@args}
