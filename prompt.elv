use math
use str

fn prompt-git-branch-color {
  var staged = 0
  var unstaged = 0
  for line [(timeout 1 git status --porcelain)] {
    if (str:contains-any $line[0] "ADM") {
      set staged = (+ $staged 1)
    } elif (str:contains-any $line[1] "ADM") {
      set unstaged = (+ $unstaged 1)
    }
  }

  put $staged $unstaged
}

fn prompt-git-ref {
  var upstream = (git branch --list --sort -HEAD --format='%(upstream:remotename)' | head -1)
  var refname = (git branch --list --sort -HEAD --format='%(refname:short)' | head -1)
  var detached-prefix = "(HEAD detached at "
  if (str:has-prefix $refname $detached-prefix) {
    set refname = (str:trim-prefix (str:trim-suffix $refname ")") $detached-prefix)
    if (str:contains $refname "/") {
      set upstream = "-detached-"
    } elif (!=s (git rev-parse --short $refname) $refname) {
      set upstream = "-tag-"
    } else {
      set upstream = "-hash-"
    }
  } elif (==s "" $upstream) {
    set upstream = "-none-"
  }
  put "("$upstream":"$refname")"
}

fn prompt-styled {
  try {
    var ref = (prompt-git-ref)
    var staged unstaged = (try {
      (prompt-git-branch-color)
    } catch {
      fail [&msg=timeout &ref=$ref]
    })
    if (and (!= 0 $staged) (!= 0 $unstaged)) {
      var length = (count $ref)
      var total = (+ $staged $unstaged)
      var pct-staged = (/ $staged $total)
      var index-rational = (* $pct-staged $length)
      var index = (math:min (- $length 1) (math:max 1 (math:round $index-rational)))
      put " " (styled $ref[..$index] "green") (styled $ref[$index..] "yellow")
    } elif (!= 0 $staged) {
      put " " (styled $ref "green")
    } elif (!= 0 $unstaged) {
      put " " (styled $ref "yellow")
    } else {
      put " " (styled $ref "blue")
    }
  } catch e {
    if (and (==s $e[reason][type] fail) (==s $e[reason][content][msg] timeout)) {
      put " " (styled $e[reason][content][ref] "#707070")
    } else {
      put (styled " (-no-refs-)" "yellow")
    }
  }
}

set edit:prompt = {
  put (date '+%a %H:%M:%S') " " (styled (print (cat /etc/hostname)) green)
  var is_git_repo = ?(git rev-parse --is-inside-work-tree > /dev/null 2>&1)
  var is_bare = $false
  if $is_git_repo {
    set is_bare = (==s "true" (git rev-parse --is-bare-repository))
  }
  if $is_bare {
    put " " (styled (print (basename (git rev-parse --absolute-git-dir))) magenta)
  } elif $is_git_repo {
    put " " (styled (print (basename (git rev-parse --show-toplevel))) magenta)
  }
  put " " (styled (print (basename (tilde-abbr $pwd))) cyan)
  if $is_bare {
    put (styled " (-none-:-bare-)" "#707070")
  } elif $is_git_repo {
    put (prompt-styled)
  }
  put (styled " -> " green)
}

set edit:rprompt = { put "" }
