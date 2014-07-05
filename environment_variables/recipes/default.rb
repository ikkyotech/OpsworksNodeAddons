Chef::Log.info("Setting environment variables")

Chef::Log.info("Adding ec2 environment variables")
node[:environment_variables]["EC2_INSTANCE_ID"] = `/opt/aws/bin/ec2-metadata -i`[/ (?<a>.*)n?$/, "a"]
node[:environment_variables]["EC2_AVAIL_ZONE"] = `/opt/aws/bin/ec2-metadata -z`[/ (?<a>.*)n?$/, "a"]
node[:environment_variables]["EC2_PUBLIC_IP4"] = `/opt/aws/bin/ec2-metadata -z`[/ (?<a>.*)n?$/, "a"]
node[:environment_variables]["HOST_NAME"] = `/opt/aws/bin/ec2-metadata -p`[/ (?<a>.*)n?$/, "a"]

Chef::Log.info("Setting environment variables for current process")
node[:environment_variables].each do |name, value|
	ENV["#{name}"] = "#{value}"
end

Chef::Log.info("Writing variables to /etc/environment to have them after restart")
template "/etc/environment" do
	source "environment.erb"
	mode "0644"
	owner "root"
	group "root"
	variables({
		:environment_variables => node[:environment_variables]
	})
end

Chef::Log.info("Creating shell file to export variables")
template "/usr/local/bin/environment.sh" do
	source "environment.sh.erb"
	mode "0755"
	owner "root"
	group "root"
end

Chef::Log.info("Exporting variables for every new created process")
execute "/usr/local/bin/environment.sh" do
	user "root"
	action :run
end

