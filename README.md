Vagrant + DSpace = vagrant-dspace
=================================

[Vagrant](http://vagrantup.com) can be used to spin up a temporary Virtual Machine (VM) in a variety of providers (VirtualBox, VMWare, AWS, etc).
The `Vagrantfile` in this folder (along with associated provision scripts) configures a DSpace development environment via Vagrant (and Puppet). 

Some Advantages for DSpace Development: 
* Using Vagrant would allow someone to spin up an "offline" copy of DSpace on your local machine/laptop for development or demo purposes.
* Vagrant VMs are "throwaway". Can easily destroy and recreate at will for testing purposes or as needs arise (e.g. vagrant destroy; vagrant up)

_BIG WARNING: THIS IS STILL A WORK IN PROGRESS. YOUR MILEAGE MAY VARY. NEVER USE THIS IN PRODUCTION._

What Works
----------

* Spins up an Ubuntu VM using Vagrant (VirtualBox backend is only one tested so far.)
* Setup SSH Forwarding, so that you can use your SSH key(s) on VM (for GitHub clones/commits)
* Sync your local Git settings (name & email) to VM
* Install some of the basic prerequisites for DSpace Development (namely: Git, Java, Maven)
* Clone DSpace source from GitHub to `~/dspace-src/` (under the default 'vagrant' user account)
* Install/Configure PostgreSQL (Thanks to [hardyoyo](https://github.com/hardyoyo/)!)
   * We install [puppetlabs/postgresql](http://forge.puppetlabs.com/puppetlabs/postgresql) (via [librarian-puppet](http://librarian-puppet.com/)),
     and then use that Puppet module to setup PostgreSQL
* Installs Tomcat (Thanks to [hardyoyo](https://github.com/hardyoyo/)!)
   * We install [camptocamp/puppet-tomcat](https://github.com/camptocamp/puppet-tomcat/) (via [librarian-puppet](http://librarian-puppet.com/)),
     and then use that Puppet module to setup Tomcat
   * WARNING: We are just pulling down the latest "master" code from camptocamp/puppet-tomcat at this time.



**If you want to help, please do.** I'd prefer solutions using [Puppet](https://puppetlabs.com/).

How To Use vagrant-dspace
--------------------------

1. Install [Vagrant](http://vagrantup.com) (I've only tested with the [VirtualBox](https://www.virtualbox.org/) provider so far)
2. Clone a copy of 'vagrant-dspace' to your local computer
3. _WINDOWS ONLY_ : Any users of Vagrant from Windows MUST create a GitHub-specific SSH Key (at `~/.ssh/github_rsa`) which is then connected to your GitHub Account. There are two easy ways to do this:
   * Install [GitHub for Windows](http://windows.github.com/) - this will automatically generate a new `~/.ssh/github_rsa` key.
   * OR, manually generate a new `~/.ssh/github_rsa` key and associate it with your GitHub Account. [GitHub has detailed instructions on how to do this.](https://help.github.com/articles/generating-ssh-keys)
   * SIDENOTE: Mac OSX / Linux users do NOT need this, as Vagrant's SSH Key Forwarding works properly from Mac OSX & Linux. There's just a bug in using Vagrant + Windows.
4. `cd [vagrant-dspace]/`
5. `vagrant up`

The `vagrant up` command will initialize a new VM based on the settings in the `Vagrantfile` in that directory.  

In a few minutes, you'll have a fresh Ubuntu VM that you can SSH into by simply typing `vagrant ssh`. Since SSH Forwarding is enabled,
that Ubuntu VM should have access to your local SSH keys, which allows you to immediately use Git/GitHub.

_Of course, there's not much to look at (yet)._ You'll just have a fresh Ubuntu virtual server with DSpace GitHub cloned (at `~/dspace-src`) and Java/Maven/Ant/Git installed.
Still, it's enough to get you started with developing/building DSpace (or debug issues with the DSpace build process, if any pop up).

It's also worth noting that you can tweak the default [`Vagrantfile`](https://github.com/tdonohue/vagrant-dspace/blob/master/Vagrantfile) to better match your own development environment. There's even a few quick settings there to get you started.

If you want to destroy the VM at anytime (and start fresh again), just run `vagrant destroy`. No worries, you can always recreate a new VM with another `vagrant up`.

Plugins
-------

The following Vagrant plugins are not necessarily required, but they do make using Vagrant more enjoyable.

* Land Rush: https://github.com/phinze/landrush
* Vagrant-Cachier: https://github.com/fgrehm/vagrant-cachier
* Vagrant-Proxyconf: http://vagrantplugins.com/plugins/vagrant-proxyconf/
* Vagrant-VBox-Snapshot: http://vagrantplugins.com/plugins/vagrant-vbox-snapshot/

License
-------

This work is licensed under the [DSpace BSD 3-Clause License](http://www.dspace.org/license/), which is just a standard [BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause).
