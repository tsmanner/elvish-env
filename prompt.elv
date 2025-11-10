use math
use str

var color = "green"

fn after-command {|args|
  if (is $nil $args[error]) {
    set color = "green"
  } else {
    set color = "red"
  }
}

set edit:after-command = [ $@edit:after-command $after-command~ ]

fn git-branch-color {
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

fn git-ref {
  var upstream @_ = (git branch --list --sort -HEAD --format='%(upstream:remotename)' | head -1) ""
  var refname @_ = (git branch --list --sort -HEAD --format='%(refname:short)' | head -1) ""
  var sep = "?"
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
  } else {
    set sep = (git branch --list --sort -HEAD --format='%(upstream:trackshort)' | head -1)
  }
  put "("$upstream$sep$refname")"
}

fn git-info {
  var is_git_repo = ?(git rev-parse --is-inside-work-tree > /dev/null 2>&1)
  if (not $is_git_repo) {
    return
  } elif (==s "true" (git rev-parse --is-bare-repository)) {
    put (styled (print (basename (git rev-parse --absolute-git-dir))) magenta)
    put (styled " (-none-:-bare-)" "#707070")
  } else {
    put (styled (print (basename (git rev-parse --show-toplevel))) magenta)
    try {
      var ref = (git-ref)
      var staged unstaged = (try {
        git-branch-color
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
      put $e
      if (and (has-key $e reason) (and (==s $e[reason][type] fail) (==s $e[reason][content][msg] timeout))) {
        put " " (styled $e[reason][content][ref] "#707070")
      } else {
        put $e
        put (styled " (-no-refs-)" "yellow")
      }
    }
  }
}

fn time {
  date '+%a %H:%M:%S'
}

fn host {
  styled (print (hostname -s)) $color
}

fn directory {
  styled (print (basename (tilde-abbr $pwd))) cyan
}

fn arrow {
  styled "-> " $color
}

var tokens = [
  $time~
  $host~
  $git-info~
  $directory~
  $arrow~
]

fn prompt {
  var delim = ""
  for token $tokens {
    if (not (is "" $token)) {
      set token = [ ($token) $nil ][0]
    }
    if $token {
      put $delim
      set delim = " "
      put $token
    }
  }
}

set edit:prompt = $prompt~
