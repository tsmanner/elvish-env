use str

#
# git namespaced functions
#

fn fetch {|@remotes|
  for remote $remotes {
    e:git fetch $remote
  } else {
    e:git fetch
  }
}

fn log {|@args|
  e:git log --pretty=oneline $@args
}

#
# Export function variables into the REPL's default namespace.
#

edit:add-var s~ {|@args| e:git status $@args }
edit:add-var d~ {|@args| e:git diff $@args }

# Map some git sub-commands onto their `git:<name>` functions
edit:add-var git~ {|subcommand @args|
  if     (==s $subcommand "fetch") { fetch $@args
  } elif (==s $subcommand "log"  ) { log   $@args
  } else { e:git $subcommand $@args
  }
}
