use str

fn prompt-git-branch-color {
  added = 0
  modified = 0
  for line [(git status --porcelain)] {
    if (==s $line[0] "M") {
      added = (+ $added 1)
    } elif (==s $line[1] "M") {
      modified = (+ $modified 1)
    }
  }

  if (!= $added 0) {
    put "green"
  } elif (!= $modified 0) {
    put "yellow"
  } else {
    put "blue"
  }
}

fn extract-git-branch-name {
  for line [ (git branch --format='%(HEAD)%(refname)') ] {
    detached-head-prefix = "*(HEAD detached at "
    if (str:has-prefix $line $detached-head-prefix) {
      ref = (str:trim-prefix (str:trim-suffix $line ")") $detached-head-prefix)
      if (str:contains $ref "/") {
        put "-detached-:"$ref
      } else {
        put "-tag-:"$ref
      }
    }
  }
}

fn prompt-git-ref {
  upstream = [ (str:split "/" (git for-each-ref --format='%(upstream:short)' (git rev-parse --symbolic-full-name HEAD))) ][0]
  try {
    put $upstream":"(git symbolic-ref -q --short HEAD)
  } except e {
    try {
      ref = (basename (git rev-parse --symbolic-full-name HEAD))
      if (!=s $ref "HEAD") {
        put $upstream":"$ref
      } else {
        put (extract-git-branch-name)
      }
    }
  }
}

edit:prompt = {
  put (date '+%a %H:%M:%S') " " (styled (print (hostname)) green)
  is_git_repo = ?(git branch > /dev/null 2>&1)
  if $is_git_repo {
    put " " (styled (print (basename (git rev-parse --show-toplevel))) magenta)
  }
  put " " (styled (print (basename (tilde-abbr $pwd))) cyan)
  if $is_git_repo {
    put " " (styled (print "("(prompt-git-ref)")") (prompt-git-branch-color))
  }
  put (styled " -> " green)
}

edit:rprompt = { put "" }
