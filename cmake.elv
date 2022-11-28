use file
use str

fn get-default-conf {
  var default-conf = [&]
  set default-conf[src-dir] = (git rev-parse --show-toplevel)
  set default-conf[build-dir] = (git rev-parse --show-toplevel)/build
  set default-conf[test-target] = tests
  put $default-conf
}

fn merge-default-conf {|conf|
  var merged = [&]
  var default-conf = (get-default-conf)
  for key [(keys $default-conf)] {
    if (has-key $conf $key) {
      set merged[$key] = $conf[$key]
    } else {
      set merged[$key] = $default-conf[$key]
    }
  }
  put $merged
}

fn get-conf {
  var conf-file = (git rev-parse --show-toplevel)/conf.elv
  # Read the full contents of the config file, if it exists.
  if (not ?(test -e $conf-file)) {
    put (get-default-conf)
  } else {
    var conf-content = (cat $conf-file | slurp)
    eval &on-end={|conf|
      put (merge-default-conf $conf)
    } $conf-content
  }
}

# Prefer Ninja as the build system to generate for.
var cmake-generator = [
  &cmake-name=(if ?(nop (which ninja)) { put "Ninja" } else { put "Unix Makefiles" })
  &name=(if ?(nop (which ninja)) { put "ninja" } else { put "make" })
]

# Use the generator specified by cmake-generator when configuring.
fn configure {|&conf=$nil|
  var starting-dir = (pwd)
  try {
    if (not $conf) { set conf = (get-conf) }
    mkdir -p $conf[build-dir]
    cd $conf[build-dir]
    cmake -G $cmake-generator[cmake-name] $@args $conf[src-dir]
  } catch {
    nop
  }
  cd $starting-dir
}

fn test {|&clear=$false &conf=$nil|
  # Capture the current directory so we can cd back before exiting.
  var starting-dir = (pwd)
  try {
    # If the user requested a screen clear, do it.
    if $clear { e:clear }
    # Get the local configuration.
    if (not $conf) { set conf = (get-conf) }
    # Create the build directory if it doesn't exist yet.
    mkdir -p $conf[build-dir]
    # If it looks like we aren't configured yet, run the configure function.
    if (not ?(e:test -d $conf[build-dir]/CMakeFiles)) {
      echo "Reconfiguring"
      configure &conf=$conf
    }
    cd $conf[build-dir]
    # Build the test target
    eval (str:join " " [$cmake-generator[name] $conf[test-target]])
    # Run the tests
    $conf[build-dir]/$conf[test-target]
  } catch {
    nop
  }
  # Go back to the original directory
  cd $starting-dir
}
