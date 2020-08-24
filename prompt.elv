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

edit:prompt = {
  put (date '+%a %H:%M:%S') " " (styled (print (hostname)) green)
  is_git_repo = ?(git branch > /dev/null 2>&1)
  if $is_git_repo {
    put " " (styled (print (basename (git rev-parse --show-toplevel))) magenta)
  }
  put  " " (styled (print (basename (tilde-abbr $pwd))) cyan)
  if $is_git_repo {
    put " " (styled (print "("(basename (git rev-parse --symbolic-full-name HEAD))")") (prompt-git-branch-color))
  }
  put (styled " -> " green)
}

edit:rprompt = { put "" }
