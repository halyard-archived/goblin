class masterless(
    $codedir = '/etc/puppetlabs/code',
    $envdir = "$codedir/environments/production",
    $modulepath = "$envdir/modules:$codedir/modules",
    $manifestpath = "$envdir/manifests/site.pp",
    $bindir = '/usr/local/bin'
) {
    file { "$bindir/puppet-run":
        ensure => 'file',
        source => template('puppet-run')
    }

    file { '/etc/systemd/system/puppet-run.service':
        ensure => 'file',
        source => template('puppet-run.service')
    }

    file { '/etc/systemd/system/puppet-run.timer':
        ensure => 'file',
        source => template('puppet-run.timer')
    }

    file { '/etc/systemd/system/multi-user.target.wants/puppet-run.timer':
        ensure => 'link',
        target => '/etc/systemd/system/puppet-run.timer'
        require => File['/etc/systemd/system/puppet-run.timer']
    }
}
