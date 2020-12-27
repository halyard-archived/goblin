if $::operatingsystem == 'archlinux' {
  Service {
    provider => systemd
  }
}

include serverless
include hostname
include openssh
include pacman::automaticupgrades
include ntp

lookup('classes', Array[String], 'unique').include
