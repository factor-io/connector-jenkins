require 'spec_helper'
require 'securerandom'
require 'jenkins_api_client'

describe 'Jenkins' do
  describe 'Job' do
    before :each do
      @host = ENV['JENKINS_HOST']
      @client = JenkinsApi::Client.new(server_url: @host)
      name = "test_#{SecureRandom.hex(4)}"
      job_config =  @client.job.build_freestyle_config(name:name)
      job =  @client.job.create(name, job_config)
      @build = @client.job.list(name)[0]

      @service_instance = service_instance('jenkins_job')
      @params = { 'host' => @host, 'job' => @build }
    end

    after :each do
      @client.job.delete @build
    end

    it 'can list jobs' do
      @service_instance.test_action('list',@params) do
        content = expect_return[:payload]
        expect(content).to be_a(Array)
      end
    end

    it 'can build a job' do
      @service_instance.test_action('build',@params) do
        expect_return code: '201'
      end
    end

    it 'can get current build status' do

      @service_instance.test_action('status',@params) do
        response = expect_return

        expect(response[:payload]).to include(:status)
      end      
    end
  end
end