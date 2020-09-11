use str

fn is-process-running [pid]{
  or (e:ps -u $E:USER | each [line]{ ==s $E:SSH_AGENT_PID [(str:split " " $line)][0] })
}

fn init-ssh-agent {
  print "Starting ssh-agent\n"
  e:ssh-agent > $E:HOME/.ssh/agent-info
}

fn export-ssh-agent-info [socket pid _]{
  E:SSH_AUTH_SOCK=[(str:split ";" [(str:split "=" $socket)][1])][0]
  E:SSH_AGENT_PID=[(str:split ";" [(str:split "=" $pid)][1])][0]
  if (not (is-process-running $E:SSH_AGENT_PID)) {
    fail (str:join "" ["ssh-agent(" $E:SSH_AGENT_PID ") not found"])
  } else {
    print (str:join "" ["Connected to ssh-agent(" $E:SSH_AGENT_PID ") on " $E:SSH_AUTH_SOCK])
  }
}

fn load-ssh-agent-info {
  try {
    export-ssh-agent-info (e:cat $E:HOME/.ssh/agent-info)
  } except {
    init-ssh-agent
    load-ssh-agent-info
  }
}

fn kill-all-ssh-agents {
  e:ps -u $E:USER | each [line]{ if (str:contains $line "ssh-agent") { kill [(str:split " " $line)][0] } }
}

load-ssh-agent-info
