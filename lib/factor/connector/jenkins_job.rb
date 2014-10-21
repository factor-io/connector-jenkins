require 'factor-connector-api'
require 'jenkins_api_client'

Factor::Connector.service 'jenkins_job' do

  action 'list' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    filter   = params['filter']
    status   = params['status']


    fail 'Host (host) is requires' unless host

    connection_settings = { server_ip: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password


    client = JenkinsApi::Client.new connection_settings

    jobs = if filter
      client.job.list_details(filter)
    elsif status
      client.job.list_by_status(status)
    else
      client.job.list_all_with_details
    end

    action_callback jobs
  end

  action 'build' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    id       = params['job']

    fail 'Host (host) is required' unless host
    fail 'Job ID (job) is required' unless id

    connection_settings = { server_ip: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings

    code = client.job.build(id)

    fail "Unable to build job: #{id}" unless code == '201'

    action_callback code: code
  end

  action 'stop' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    id       = params['job']
    build    = params['build'] || 0

    fail 'Host (host) is required' unless host
    fail 'Job ID (job) is required' unless id

    connection_settings = { server_ip: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings

    code = client.job.stop_build(id, build)

    fail "Unable to stop job: #{id}" unless code == '302'

    action_callback code: code
  end

  action 'status' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    id       = params['job']

    fail 'Host (host) is required' unless host
    fail 'Job ID (job) is required' unless id

    connection_settings = { server_ip: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings

    status = client.job.get_current_build_status(id)

    action_callback status:status
  end

  action 'rename' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    id       = params['job']
    new_id   = params['new_job']

    fail 'Host (host) is required' unless host
    fail 'Job ID (job) is required' unless id
    fail 'New Job ID (new_id) is required' unless new_id

    connection_settings = { server_ip: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings

    code = client.job.rename(id, new_id)

    fail "Unable to rename job '#{id} to #{new_id}'" unless code == '302'

    action_callback code: code
  end

end