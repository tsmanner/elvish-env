edit:prompt = {
  put (date '+%a %H:%M:%S') " " (hostname) " " (tilde-abbr $pwd)
  if ?(git branch > /dev/null 2>&1) {
    put (styled ("(" (git branch) ")") yellow)
  }
  put (styled " -> " green)
}
