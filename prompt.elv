edit:prompt = {
  put "("
  tilde-abbr $pwd
  put ") "
  put (styled "~ " if $? { green } else { red })
}
