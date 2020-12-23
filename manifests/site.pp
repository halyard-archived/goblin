if $::operatingsystem == :archlinuxx {
  Service {
    provider => systemd
  }
}

include serverless
include hostname
include openssh
