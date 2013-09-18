# Configuration for librarian-puppet (http://librarian-puppet.com/)
# This installs necessary third-party Puppet Modules for us.

# Install Puppet PostgreSQL module from PuppetForge
forge "http://forge.puppetlabs.com"
mod "puppetlabs/postgresql"

# Install the Saz vim module, so we can have vim on this box
mod "saz/vim"

# Install Tim's simple Tomcat module from GitHub
mod "tomcat",
   :git => "http://github.com/tdonohue/puppet-tomcat.git"

# Install the Puppetlabs Apache module, to use as a reverse proxy, and to use for supporting software development (such as DSpace QC Tools).
mod "puppetlabs/apache"
