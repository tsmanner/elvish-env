# Default rc.elv file which will pull and load the modules here
use epm      # Load the Elvish Package Manager module
epm:upgrade  # Upgrade installed modules

epm:install github.com/tsmanner/elvish-env  # Install this repo

use github.com/tsmanner/elvish-env/prompt     # Load the prompt
# use github.com/tsmanner/elvish-env/ssh-agent  # Start up and connect to an ssh-agent


