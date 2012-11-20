class patch {
  if !defined(Package['patch']) {
    package { 'patch':
      ensure => present
    }
  }
}
