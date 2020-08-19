edit:prompt = {
  put (date '+%a %H:%M:%S') " " (styled (print (hostname)) green)
  if ?(git branch > /dev/null 2>&1) {
    put " " (styled (print (basename (git rev-parse --show-toplevel))) magenta) (styled (print " ("(git rev-parse --symbolic-full-name HEAD)")") yellow)
  }
  put  " " (styled (print (basename (tilde-abbr $pwd))) cyan) (styled " -> " green)
}

edit:rprompt = { put "" }
