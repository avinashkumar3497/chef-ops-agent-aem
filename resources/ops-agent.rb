provides :gcp_ops_agent_configuration
unified_mode true
resource_name :gcp_ops_agent_configuration
default_action :create

# property :environment, String, required: true
# property :platform, String, required: true
# property :role, String, required: true
# property :server, String, required: true

# ── 1. Add Google's apt repository ───────────────────────────────────────
# this section needs to be removed in actual execution
apt_repository 'google-cloud-ops-agent' do
  uri          'https://packages.cloud.google.com/apt'
  distribution 'google-cloud-ops-agent-noble-all'
  components   ['main']
  key          'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
  action       :add
end

action :create do
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

  # files_list = ['apache.conf', 'syslog.conf', 'aem.conf']

#   files_list.each do |file|
#     cookbook_file "/etc/ops-agent/config.d/#{file}" do
#       source "#{file}"
#       cookbook 'gcp-monitoring'
#       owner 'root'
#       group 'root'
#       mode '0644'
#       action :create
#       notifies :restart, 'service[google-fluentd]', :delayed
#     end
#   end

#   template '/etc/google-cloud-ops-agent/config.yaml' do ##############################check this
#     source 'config.yaml.erb'                ##############################check this
#     #cookbook 'gcp-monitoring-v1'
#     owner 'root'
#     group 'root'
#     mode '0644'
#     # variables(
#     #   environment: new_resource.environment,
#     #   platform: new_resource.platform,
#     #   role: new_resource.role,
#     #   server: new_resource.server
#     # )
#     action :create
#     notifies :restart, 'service[google-cloud-ops-agent]', :delayed        ##############################check this
#   end

  file '/etc/google-cloud-ops-agent/config.yaml' do
    owner   'root'
    group   'root'
    mode    '0644'
    content <<~YAML
      logging:
        receivers:
          aem_logs:
            type: files
            include_paths:
              - /aem/author/crx-quickstart/logs/access.log
              - /aem/author/crx-quickstart/logs/request.log
        exporters:
          google_cloud_logging:
            type: google_cloud_logging
        service:
          pipelines:
            aem_pipeline:
              receivers: [aem_logs]
              exporters: [google_cloud_logging]
    YAML
    action  :create
    notifies :restart, 'service[google-cloud-ops-agent]', :delayed
  end

  service 'google-cloud-ops-agent' do
    action [:enable, :start]
  end

# TODO: delete old tmp logs
end
