class masterless(
    $codedir = '/etc/puppetlabs/code',
    $envdir = "$codedir/environments/production"
    $modulepath = "$envdir/modules:$codedir/modules"
    $manifestpath = "$envdir/manifests/site.pp"
) {
    file { '/usr/local/bin/puppet_apply':
        ensure => 'file',       
    }
}
