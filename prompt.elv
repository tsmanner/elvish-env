edit:prompt = {
  put (date '+%a %H:%M:%S') " " (styled (print (hostname)) green)
  is_git_repo = ?(git branch > /dev/null 2>&1)
  if $is_git_repo {
    put " " (styled (print (basename (git rev-parse --show-toplevel))) magenta)
  }
  put  " " (styled (print (basename (tilde-abbr $pwd))) cyan) (styled " -> " green)
  if $is_git_repo {
    put " " (styled (print "("(git rev-parse --symbolic-full-name HEAD)")") yellow)
  }
}

edit:rprompt = { put "" }
