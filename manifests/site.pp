if $::operatingsystem == 'archlinux' {
  Service {
    provider => systemd
  }
}

include serverless
include hostname
include openssh
include pacman::automaticupgrades

hiera_include(classes)
