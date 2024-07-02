try {
    New-NetFirewallRule `
      -Name blockrdpb `
      -DisplayName 'bridged block RDP port (jso)' `
      -Enabled True `
      -Direction Inbound `
      -Protocol TCP `
      -Action Deny `
      -LocalPort 3389 `
      -RemoteAddress 192.168.8.0/24
} catch {
    # Just silently fail 
    # TODO(jso): this might be awful
    exit 0
}
try {
    New-NetFirewallRule `
      -Name blockrdpv `
      -DisplayName 'virt block RDP port (jso)' `
      -Enabled True `
      -Direction Inbound `
      -Protocol TCP `
      -Action Deny `
      -LocalPort 3389 `
      -RemoteAddress 192.168.58.0/24
} catch {
    # Just silently fail 
    # TODO(jso): this might be awful
    exit 0
}

