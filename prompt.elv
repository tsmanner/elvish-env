edit:prompt = {
  put (date '+%a %H:%M:%S') " " (hostname) " " (tilde-abbr $pwd)
  if ?(git branch > /dev/null 2>&1) {
    branch_string = put "(" (git branch) ")"
    put (styled $branch_string yellow)
  }
  put (styled " -> " green)
}
