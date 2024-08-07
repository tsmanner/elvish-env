use os
use re
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

fn work {|@args|
  var git_root = (realpath (e:git rev-parse --git-common-dir))
  var root = (dirname $git_root)
  if (==s $args[0] "--done") {
    tmp args = $args[1..]
    var branch = (e:git branch --show-current)
    echo "Cleaning up worktree "$branch
    var current_pwd = (pwd)
    cd $git_root
    try {
      e:git worktree remove $branch $@args
      e:git worktree prune
      cd $root
    } catch e {
      cd $current_pwd
    }
  } else {
    # TODO: Implement a 2-parameter version that works like 'git checkout -b foo bar'
    var match = (re:find "([[:word:][:punct:]]+/)?([[:word:][:punct:]]+)" $args[0])
    var remote = $match[groups][1][text]
    var branch = $match[groups][2][text]
    var dir = $root"/"$branch
    if (os:is-dir $dir) {
      echo "Moving to work tree in "$dir
      cd $dir
    } else {
      echo "Creating work tree in "$dir
      if (==s $remote "") {
        e:git worktree add $dir $branch
      } else {
        e:git worktree add -B $branch $dir $remote"/"$branch
      }
      cd $dir
    }
  }
}

#
# Export function variables into the REPL's default namespace.
#

edit:add-var s~ {|@args| e:git status $@args }
edit:add-var d~ {|@args| e:git diff $@args }

# Map some git sub-commands onto their `git:<name>` functions
# edit:add-var git~ {|subcommand @args|
#   if     (==s $subcommand "fetch") { fetch $@args
#   } elif (==s $subcommand "work" ) { work  $@args
#   } else { e:git $subcommand $@args
#   }
# }
