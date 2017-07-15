include masterless

node infra.a-rwx.org {
  include unifi
}

node default {
  fail('No node definition exists for this node')
}
