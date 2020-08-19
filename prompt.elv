edit:prompt = {
  put (date '+%a %H:%M:%S') " " (hostname) " " (tilde-abbr $pwd)
  try {
    put (styled ("(" (git branch) ")") yellow)
  } except e { nop }
  put (styled " -> " green)
}
