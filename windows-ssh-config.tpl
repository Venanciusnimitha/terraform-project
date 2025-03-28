add-content -path c:/users/kaliraja/.ssh/config -value @'
Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
'@