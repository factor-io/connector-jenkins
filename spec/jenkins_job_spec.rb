require 'spec_helper'
require 'securerandom'
require 'jenkins_api_client'

describe JenkinsConnectorDefinition do
  describe :job do
    before :each do
      @host             = ENV['JENKINS_HOST']
      @client           = JenkinsApi::Client.new(server_url: @host)
      name              = "test_#{SecureRandom.hex(4)}"
      job_config        = @client.job.build_freestyle_config(name:name)
      job               = @client.job.create(name, job_config)
      @build            = @client.job.list(name)[0]
      @params           = { 'host' => @host, 'job' => @build }
      @runtime          = Factor::Connector::Runtime.new(JenkinsConnectorDefinition)
    end

    after :each do
      @client.job.delete @build
    end

    it 'can :list' do
      @runtime.run([:job,:list],@params)
      expect(@runtime).to respond
      data = @runtime.logs.last[:data]
      expect(data).to be_a(Array)
    end

    it 'can :build' do
      @runtime.run([:job,:list],@params)

      expect(@runtime).to respond
      data = @runtime.logs.last[:data]
      
      expect(data).to be_a(Hash)
      expect(data[:build_number]).to be_a(Integer)
      expect(data[:status]).to eq('success')
      expect(data[:console]).to be_a(Hash)
      expect(data[:console].keys).to include('output')
      expect(data[:console].keys).to include('size')
      expect(data[:console].keys).to include('more')

    end

    it 'can :status' do
      @runtime.run([:job,:status],@params)

      expect(@runtime).to respond
      data = @runtime.logs.last[:data]
      
      expect(data).to be_a(Hash)
      expect(data).to include(:status)
    end
  end
end