require 'spec_helper'
require 'securerandom'
require 'jenkins_api_client'

describe 'jenkins' do
  describe ':: jobs' do
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

    it ':: list' do
      @service_instance.test_action('list',@params) do
        content = expect_return[:payload]
        expect(content).to be_a(Array)
      end
    end

    it ':: build' do
      @service_instance.test_action('build',@params) do
        content = expect_return[:payload]

        expect(content).to be_a(Hash)
        expect(content[:build_number]).to be_a(Integer)
        expect(content[:status]).to eq('success')
      end
    end

    it ':: status' do

      @service_instance.test_action('status',@params) do
        response = expect_return

        expect(response[:payload]).to include(:status)
      end      
    end
  end
end