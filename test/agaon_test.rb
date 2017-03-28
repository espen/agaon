require 'test_helper'

class AgaonTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Agaon::VERSION
  end
end

class ClientTest < Minitest::Test
  def test_companies
    VCR.use_cassette('companies') do
      fiken = Agaon::Client.new(
        ENV['FIKEN_USERNAME'],
        ENV['FIKEN_PASSWORD']
      )
      companies = fiken.companies
      assert companies.any?
      assert_equal 'Fiken-demo - Klar fly AS', companies.first['name']
    end
  end

  def test_save_contact
    VCR.use_cassette("save_contact") do
      fiken = Agaon::Client.new(
        ENV['FIKEN_USERNAME'],
        ENV['FIKEN_PASSWORD'],
        ENV['FIKEN_COMPANY_HREF']
      )
      contact_attributes = {
        name: 'Agaon User'
      }
      assert contact_href = fiken.contact(contact_attributes)
      fetch_new_contact = fiken.get_contact(contact_href)
      assert_equal contact_attributes[:name], fetch_new_contact['name']
    end
  end
end