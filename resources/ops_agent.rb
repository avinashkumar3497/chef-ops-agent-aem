# Cookbook:: gcp-monitoring
# Recipe:: ops_agent

provides :gcp_ops_agent_configuration
unified_mode true
resource_name :gcp_ops_agent_configuration
default_action :create

property :environment, String, required: true
property :platform, String, required: true
property :role, String, required: true
property :server, String, required: true

action :create do
  # ── 1. Add Google's apt repository ───────────────────────────────────────
  # this section needs to be removed in actual execution
  apt_repository 'google-cloud-ops-agent' do
    uri          'https://packages.cloud.google.com/apt'
    distribution 'google-cloud-ops-agent-noble-all'
    components   ['main']
    key          'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    action       :add
  end
  #──────────────────────────────────────

  package 'google-cloud-ops-agent' do
    action :install
  end

  directory '/etc/google-cloud-ops-agent' do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  template '/etc/google-cloud-ops-agent/config.yaml' do
    source 'ops_agent_config.yaml.erb'
    cookbook 'gcp-monitoring-v1'
    owner  'root'
    group  'root'
    mode   '0644'
    variables(
      environment: new_resource.environment,
      platform: new_resource.platform,
      role: new_resource.role,
      server: new_resource.server
    )
    action :create
    # need to be moved to file section later
    notifies :restart, 'service[google-cloud-ops-agent]', :delayed
  end

  service 'google-cloud-ops-agent' do
    action [:enable, :start]
  end

# TODO: delete old tmp logs
end
