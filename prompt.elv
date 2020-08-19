edit:prompt = {
  put (date '+%a %H:%M:%S') " " (styled (print (hostname)) green)
  is_git_repo = ?(git branch > /dev/null 2>&1)
  if $is_git_repo {
    put " " (styled (print (basename (git rev-parse --show-toplevel))) magenta)
  }
  put  " " (styled (print (basename (tilde-abbr $pwd))) cyan)
  if $is_git_repo {
    put " " (styled (print "("(git rev-parse --symbolic-full-name HEAD)")") yellow)
  }
  put (styled " -> " green)
}

edit:rprompt = { put "" }
