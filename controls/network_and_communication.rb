mongo_conf_file = attribute('conf_file', default: '/etc/mongod.conf', description: 'Path to the mongod.conf file')


title "Network and Communication"

conf_file = yaml(mongo_conf_file)

control "mongod-network-1" do
  title "SSL is enabled"
  desc "Enabling SSL ensures communication to mongod is secure"
  impact 0.6

  describe conf_file do
    its(["net", "ssl", "mode"]) { should eq "requireSSL" }
    its(["net", "ssl", "PEMKeyFile"]) { should_not be_nil }
  end
end

control "mongod-network-2" do
  title "HTTP-based interfaces are disabled"
  desc "MongoDB recommends all HTTP-based interfaces are disabled in production to avoid data leakage."

  describe conf_file do
    its(["net", "http", "enabled"]) { should eq false }
    its(["net", "http", "JSONPEnabled"]) { should eq false }
    its(["net", "http", "RESTInterfaceEnabled"]) { should eq false }
  end
end

control "mongod-network-3" do
  title "Bind to localhost"
  desc "
    Whenever possible, do not expose MongoDB instances to publicly-accessible interfaces.
    If having MongoDB be accessible to other machines, skip this control.
  "
  impact 0.1

  describe conf_file do
    its(["net", "bindIp"]) { should cmp "127.0.0.1" }
  end
end

control "mongod-network-4" do
  title "Wirechecking payload is enabled"
  desc "mongod should validate all requests on receipt to prevent clients inserting malformed data"
  impact 0.1

  describe conf_file do
    its(["net", "wireObjectCheck"]) { should eq true }
  end
end
