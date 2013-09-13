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



# BEGIN PostgreSQL configuration ################

# Install PostgreSQL package
#class { 'postgresql':
#  charset => 'UTF8',
#}

#->

# Setup/Configure PostgreSQL server
#class { 'postgresql::server':
#  config_hash => {
#    'listen_addresses'           => '*',
#    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
#    'ip_mask_allow_all_users'    => '0.0.0.0/0',
#    'manage_redhat_firewall'     => true,
#    'manage_pg_hba_conf'         => true,
#    'postgres_password'          => 'dspace',
#  },
#}

#->

# Create a 'dspace' database
#postgresql::db { 'dspace':
#  user     => 'dspace',
#  password => 'dspace'
#}

# END PostgreSQL configuration ####################

# BEGIN Oracle configuration ######################
# (Note: to use the following, you will want to comment out the PostgreSQL configuration above)

 oradb::installdb{ '112010_Linux-x86-64':
        version                => '11.2',
        file                   => 'linux.x64_11gR2_database',
        databaseType           => 'SE',
        oracleBase             => '/oracle',
        oracleHome             => '/oracle/product/11.2/db',
        createUser             => true,
        user                   => 'oracle',
        group                  => 'dba',
        downloadDir            => '/install',
        zipExtract             => true,
        puppetDownloadMntPoint => '/vagrant/oracle'
 }

 oradb::listener{'stop listener':
        oracleBase   => '/oracle',
        oracleHome   => '/oracle/product/11.2/db',
        user         => 'oracle',
        group        => 'dba',
        action       => 'start',  
        require      => Oradb::Net['config net8'],
 }


 oradb::listener{'start listener':
        oracleBase   => '/oracle',
        oracleHome   => '/oracle/product/11.2/db',
        user         => 'oracle',
        group        => 'dba',
        action       => 'start',  
        require      => Oradb::Listener['stop listener'],
 }


 oradb::database{ 'dspaceDb_Create': 
                  oracleBase              => '/oracle',
                  oracleHome              => '/oracle/product/11.2/db',
                  version                 => '11.2' or "12.1", 
                  user                    => 'oracle',
                  group                   => 'dba',
                  downloadDir             => '/install',
                  action                  => 'create',
                  dbName                  => 'dspace',
                  dbDomain                => 'oracle.com',
                  sysPassword             => 'dspace',
                  systemPassword          => 'dspace',
                  dataFileDestination     => "/oracle/oradata",
                  recoveryAreaDestination => "/oracle/flash_recovery_area",
                  characterSet            => "AL32UTF8",
                  nationalCharacterSet    => "UTF8",
                  initParams              => "open_cursors=1000,processes=600,job_queue_processes=4",
                  sampleSchema            => 'TRUE',
                  memoryPercentage        => "40",
                  memoryTotal             => "800",
                  databaseType            => "MULTIPURPOSE",                         
                  require                 => Oradb::Listener['start listener'],
 }

oradb::dbactions{ 'stop dspaceDb': 
                 oracleHome              => '/oracle/product/11.2/db',
                 user                    => 'oracle',
                 group                   => 'dba',
                 action                  => 'stop',
                 dbName                  => 'dspace',
                 require                 => Oradb::Database['dspaceDb'],
}

oradb::dbactions{ 'start dspaceDb': 
                 oracleHome              => '/oracle/product/11.2/db',
                 user                    => 'oracle',
                 group                   => 'dba',
                 action                  => 'start',
                 dbName                  => 'dspace',
                 require                 => Oradb::Dbactions['stop dspaceDb'],
}



oradb::database{ 'dspaceDb_Delete': 
                  oracleBase              => '/oracle',
                  oracleHome              => '/oracle/product/11.2/db',
                  user                    => 'oracle',
                  group                   => 'dba',
                  downloadDir             => '/install',
                  action                  => 'delete',
                  dbName                  => 'dspace',
                  sysPassword             => 'dspace',
                  require                 => Oradb::Dbactions['start dspaceDb'],
}

# END Oracle database configuration #####################################################################



include tomcat

# Create a new Tomcat instance
tomcat::instance { 'dspace':
   owner => "vagrant",
   appBase => "/home/vagrant/dspace/webapps", # Tell Tomcat to load webapps from this directory
   ensure    => present,
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

