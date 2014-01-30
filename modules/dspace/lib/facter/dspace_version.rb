# dspace_version.rb

require 'facter'
Facter.add("dspace_version") do
   confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]
   setcode do
       Facter::Util::Resolution.exec("curl -s https://github.com/DSpace/DSpace/blob/master/pom.xml | grep -E -m 1 -o '<version>(.*)</version>' | sed -e 's,<version>\([^<]*\)</version>,\1,g'")
   end
end
