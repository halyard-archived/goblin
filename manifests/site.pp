include masterless
include hostname

node 'infra.a-rwx.org' {
  include unifi
}

node default {
  fail('No node definition exists for this node')
}
