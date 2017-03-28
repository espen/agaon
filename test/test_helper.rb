$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'agaon'
require 'minitest/autorun'

require 'vcr'
require 'dotenv/load'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :faraday
  config.before_record do |i|
    i.response.headers.delete('set-cookie')
    i.request.headers.delete('Authorization')
  end
end