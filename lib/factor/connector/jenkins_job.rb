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

    connection_settings = { server_url: host }
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
    username                      = params['username']
    password                      = params['password']
    host                          = params['host']
    id                            = params['job']
    job_params                    = params['params'] || {}
    build_start_timeout           = params['build_start_timeout'] || 60*5
    cancel_on_build_start_timeout = params['cancel_on_build_start_timeout'] || true

    fail 'Host (host) is required' unless host
    fail 'Job ID (job) is required' unless id

    connection_settings = { server_url: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings

    opts = {
      'build_start_timeout'           => build_start_timeout,
      'cancel_on_build_start_timeout' => cancel_on_build_start_timeout,
      'poll_interval'                 => 5,
      'completion_proc'               => lambda {|build_number,canceled|
        fail 'Build was canceled before it completed' if canceled
      }
    }

    info 'Starting the build job. Waiting in queue.'
    begin
      build_number = client.job.build(id, job_params, opts)
      info "Build started with ID: #{build_number}"
    rescue => ex
      fail "Exception in Jenkins: #{ex.message}"
    end

    info "Waiting for build to complete"
    begin
      status  = client.job.get_current_build_status(id)
      sleep 2
    end while status == 'running'
    info "Build complete with status: #{status}"

    info 'Getting console output'
    console = client.job.get_console_output(id,build_number) 

    action_callback build_number: build_number, status: status, console: console

  end

  action 'status' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    id       = params['job']

    fail 'Host (host) is required' unless host
    fail 'Job ID (job) is required' unless id

    connection_settings = { server_url: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings

    status = client.job.get_current_build_status(id)

    action_callback status:status
  end
end