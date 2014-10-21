require 'spec_helper'

describe 'Jenkins' do
  describe 'Job' do
    it 'can list jobs' do

      username = ENV['JENKINS_HOST']

      service_instance = service_instance('jenkins_jobs')

      service_instance.test_action('list',params) do
        expect_return
      end
    end
  end
end