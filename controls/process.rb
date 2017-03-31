title "Process Security"

control "mongod-process-1" do
  title "mongod runs as non-root"
  desc "The MongoDB process should not run as the root user"
  impact 0.7

  describe processes("mongod") do
    its("users") { should_not include "root" }
  end
end
