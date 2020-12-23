if $::operatingsystem == 'ArchLinux' {
  Service {
    provider => systemd
  }
}

include serverless
include hostname
include openssh
