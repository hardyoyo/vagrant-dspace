# DSpace initialization script
#
# This Puppet script does the following:
# - installs Java, Maven, Ant
# - installs Git & clones DSpace source code
#
# Tested on:
# - Ubuntu 12.04

# Global default to requiring all packages be installed & apt-update to be run first
Package {
  ensure => latest,                # requires latest version of each package to be installed
  require => Exec["apt-get-update"],
}

# Ensure the rcconf package is installed, we'll use it later to set runlevels of services
package { "rcconf":
  ensure => "installed"
}

# Global default path settings for all 'exec' commands
Exec {
  path => "/usr/bin:/usr/sbin:/bin",
}


# Add the 'partner' repositry to apt
# NOTE: $lsbdistcodename is a "fact" which represents the ubuntu codename (e.g. 'precise')
file { "partner.list":
  path    => "/etc/apt/sources.list.d/partner.list",
  ensure  => file,
  owner   => "root",
  group   => "root",
  content => "deb http://archive.canonical.com/ubuntu ${lsbdistcodename} partner
              deb-src http://archive.canonical.com/ubuntu ${lsbdistcodename} partner",
  notify  => Exec["apt-get-update"],
}

# Run apt-get update before installing anything
exec {"apt-get-update":
  command => "/usr/bin/apt-get update",
  refreshonly => true, # only run if notified
}

# Install DSpace pre-requisites (from DSpace module's init.pp)
# If the global fact "java_version" doesn't exist, use default value in 'dspace' module
if $::java_version == undef {
    include dspace
}
else { # Otherwise, pass the value of $::java_version to the 'dspace' module
    class { 'dspace':
       java_version => $::java_version,
    }
}

# Install Vim for a more rewarding command-line-based editor experience
class {'vim':
   ensure => present,
   set_as_default => true
}

# Install PostgreSQL package
class { 'postgresql':
  charset => 'UTF8',
}

->

# Setup/Configure PostgreSQL server
class { 'postgresql::server':
  config_hash => {
    'listen_addresses'           => '*',
    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    'ip_mask_allow_all_users'    => '0.0.0.0/0',
    'manage_redhat_firewall'     => true,
    'manage_pg_hba_conf'         => true,
    'postgres_password'          => 'dspace',
  },
}

->

# Create a 'dspace' database
postgresql::db { 'dspace':
  user     => 'dspace',
  password => 'dspace'
}

# subclass tdonohue's Tomcat package
class tomcat_dspace inherits tomcat { $tomcat = "tomcat7"
    # override stuff already defined by tdonohue's module here
 
    # stop the system tomcat7 service
    # AND remove the system tomcat7 service from all runlevels
    # BECAUSE the system tomcat7 will block the following tomcat instance from loading
    service { 'tomcat7':
       name      => $tomcat,
       enable    => false,
       ensure    => present,
    }

    # use our own version of server.xml
    file { "/home/vagrant/tomcat/conf/server.xml" : 
       ensure  => file,
       owner   => vagrant,
       group   => vagrant,
       content => template("/vagrant/modules/tomcat/templates/server.xml.erb"),
       notify  => "Hey, don't forget to reboot Tomcat at some point!" # we really ought to reload this instance of Tomcat at some point, but we haven't even created the init scripts for it yet... soon.
    }

}

# and let's use our version (may not be necessary)
include tomcat_dspace

# Create a new Tomcat instance
tomcat::instance { 'dspace':
   owner => "vagrant",
   appBase => "/home/vagrant/dspace/webapps", # Tell Tomcat to load webapps from this directory
   ensure    => present,
}

->


# Copy over Tomcat configs necessary for our vagrant-owned instance of Tomcat to run

file { "/home/vagrant/tomcat/conf/tomcat-users.xml" :
    ensure  => file,
    owner   => vagrant,
    group   => vagrant,
    content => template("/vagrant/modules/tomcat/templates/tomcat-users.xml.erb"),
}

->

file { "/etc/default/tomcat7-vagrant" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template("/vagrant/modules/tomcat/templates/default-tomcat7-vagrant.erb"),
}

->

file { "/etc/init.d/tomcat7-vagrant" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template("/vagrant/modules/tomcat/templates/init-tomcat7-vagrant.erb"),
}

->

# copy (recursively) /etc/tomcat7/policy.d to /home/vagrant/tomcat/conf, since tomcat7-instance-create doesn't do this
# AND ensure vagrant:vagrant is the onwner of the policy.d folder (and its contents)
exec { "copy policy.d":
    command => "cp -r policy.d /home/vagrant/tomcat/conf/ && chown -R vagrant:vagrant /home/vagrant/tomcat/conf/policy.d",
    cwd     => "/etc/tomcat7"
}

->

# Kickoff a DSpace installation for the 'vagrant' default user
dspace::install { vagrant-dspace:
   owner   => "vagrant",
   require => [Postgresql::Db['dspace'],Tomcat::Instance['dspace']]  # Require that PostgreSQL and Tomcat are setup
}

->

# set the runlevels of tomcat7-vagrant
# AND start the tomcat7-vagrant service
service {"tomcat7-vagrant":
   enable => "true",
   ensure => "running",
}

