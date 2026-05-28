# this file will be empty in the actual execution

gcp_ops_agent_configuration 'setup' do
  environment 'int'
  platform 'cf65'
  role 'author'
  server 'node.name'
  action :create
end