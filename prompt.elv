edit:prompt = {
  hostname
  put " "
  tilde-abbr $pwd
  try {
    put (styled { "(" git branch put ")" } yellow)
  } except e { nop }
  put (styled " ~ " green)
}
