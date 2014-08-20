service { 'cronie.service':
  ensure => 'running',
  enable => 'true',
}
service { 'exim.service':
  ensure => 'running',
  enable => 'true',
}
service { 'haveged.service':
  ensure => 'running',
  enable => 'true',
}
service { 'ip6tables.service':
  ensure => 'running',
  enable => 'true',
}
service { 'iptables.service':
  ensure => 'running',
  enable => 'true',
}
service { 'ntpd.service':
  ensure => 'running',
  enable => 'true',
}
service { 'sshd.service':
  ensure => 'running',
  enable => 'true',
}
service { 'syslog-ng.service':
  ensure => 'running',
  enable => 'true',
}
service { 'systemd-networkd.service':
  ensure => 'running',
  enable => 'true',
}

