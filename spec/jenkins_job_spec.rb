require 'spec_helper'

describe 'Jenkins' do
  describe 'Job' do
    before do
      @host = ENV['JENKINS_HOST']
      @build = ENV['JENKINS_TEST_BUILD']
      @service_instance = service_instance('jenkins_job')
      @params = { 'host' => @host, 'job' => @build }
    end

    it 'can list jobs' do
      @service_instance.test_action('list',@params) do
        puts expect_return
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

    it 'can get rename' do
      params = @params.dup
      params['new_job'] = 'factor-build-new'

      @service_instance.test_action('rename',params) do
        response = expect_return
        expect(response[:payload]).to include(:code)
        expect(response[:payload][:code]).to be == '302'
      end

      params['job'] = 'factor-build-new'
      params['new_job'] = 'factor-build'
      
      @service_instance.test_action('rename',params) do
        response = expect_return
        expect(response[:payload]).to include(:code)
        expect(response[:payload][:code]).to be == '302'
      end
    end

    it 'can stop a build' do
      @service_instance.test_action('build',@params) do
        expect_return code: '201'
      end

      sleep 10

      @service_instance.test_action('stop',@params) do
        expect_return code: '302'
      end
    end
  end
end