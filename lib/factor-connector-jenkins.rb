require 'factor/connector/definition'
require 'jenkins_api_client'

class JenkinsConnectorDefinition < Factor::Connector::Definition
  id :jenkins

  def setup_client(params = {})
    username = params[:username]
    password = params[:password]
    host     = params[:host]
    fail 'Host (:host) is requires' unless host

    connection_settings = { server_url: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password

    client = JenkinsApi::Client.new connection_settings
    client
  end

  resource :job do
    action :list do |params|
      client = setup_client(params)
      
      jobs = client.job.list_all_with_details
      
      respond jobs
    end

    action :build do |params|
      client                        = setup_connection(params)
      id                            = params[:job]
      job_params                    = params[:params] || {}
      build_start_timeout           = params[:build_start_timeout] || 60*5
      cancel_on_build_start_timeout = params[:cancel_on_build_start_timeout] || true

      fail 'Job ID (:job) is required' unless id

      opts = {
        'build_start_timeout'           => build_start_timeout,
        'cancel_on_build_start_timeout' => cancel_on_build_start_timeout,
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

      respond build_number: build_number, status: status, console: console
    end

    action :status do |params|
      client = setup_connection(params)
      id     = params['job']

      fail 'Job ID (job) is required' unless id

      status = client.job.get_current_build_status(id)

      respond status:status
    end
  end
end