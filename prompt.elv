edit:prompt = {
  hostname
  put " "
  tilde-abbr $pwd
  if ?(git branch) {
    put (styled { "(" git branch put ")" } yellow)
  }
  put (styled " ~ " green)
}
