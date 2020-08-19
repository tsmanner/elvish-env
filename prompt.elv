edit:prompt = {
  put (date '+%a %H:%M:%S') " " (hostname) " " (tilde-abbr $pwd)
  if ?(git branch > /dev/null 2>&1) {
    put (styled (print "("(git rev-parse --symbolic-full-name HEAD)")") yellow)
  }
  put (styled " -> " green)
}
