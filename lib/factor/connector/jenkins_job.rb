require 'factor-connector-api'
require 'jenkins_api_client'

Factor::Connector.service 'jenkins_job' do

  action 'list' do |params|
    username = params['username']
    password = params['password']
    host     = params['host']
    filter   = params['filter']


    fail 'Host (host) is requires' unless host

    connection_settings = { host: host }
    connection_settings[:username] = username if username
    connection_settings[:password] = password if password


    client = JenkinsApi::Client.new connection_settings

    jobs = filter ? client.job.list(filter) : client.job.list_all

    action_callback jobs
  end

end