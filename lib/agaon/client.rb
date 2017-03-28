module Agaon
  class Client
    class Error < StandardError; end
    class NotAuthenticated < Error; end
    [:NotAuthenticated].each do |const|
      Error.const_set(const, Agaon::Client.const_get(const))
    end

    API_BASE = 'https://fiken.no/api/v1'

    attr_accessor :email, :password, :company_href

    def initialize(email, password, company_href=nil)
      @email = email
      @password = password
      @company_href = company_href
    end

    def who_am_i
      url = API_BASE + '/whoAmI'

      response = get(url)
      response.to_hash
    end

    def current_company
      get_company(@company_href)
    end

    def get_company(href)
      response = get(href)
      response.to_hash
    end

    [:companies, :accounts, :bank_accounts, :contacts, :products, :invoices, :sales].each do |method_name|
      define_method method_name do |*args|
        raise 'No company set' if method_name != :companies && !self.company_href
        if method_name == :companies
          base_url = API_BASE
        else
          base_url = self.company_href
        end
        url = base_url + '/' + method_name.to_s.tr('_'.freeze, '-'.freeze)
        if method_name == :accounts
          raise 'No year set' if args.length == 0
          year = args.first.to_s
          url += '/' + year
        end

        response = get(url)
        response._embedded.first.last.collect{|c|c.to_hash.merge('href' => c._links['self'].to_s) }
      end
    end

    [:account, :bank_account, :contact, :product, :invoice, :sale].each do |method_name|
      define_method method_name do |*args|
        url = self.company_href + '/' + method_name.to_s.tr('_'.freeze, '-'.freeze) + 's'
        if method_name == :account
          raise 'No year set' if args.length < 2
          year = args.first.to_s
          object = args.second
          url += '/' + year
        else
          object = args.first
        end

        response = post(url,object)
        response._response.headers[:location]
      end

      define_method "get_#{method_name}" do |href|
        response = get(href)
        response.to_hash
      end

      define_method "update_#{method_name}" do |href, object|
        response = put(href,object)
        response.to_s
      end
    end

    [:create_invoice, :create_general_journal_entry, :document_sending].each do |method_name|
      define_method method_name do |object|
        endpoint = method_name.to_s.tr('_'.freeze, '-'.freeze) + '-service'
        endpoint = 'createGeneralJournalEntriesService' if endpoint == 'create-general-journal-entry-service'
        url = self.company_href + '/' + endpoint

        response = post(url,object)
        response._response.headers[:location]
      end
    end

    def search(object)
      endpoint = 'search'
      url = self.company_href + '/' + endpoint

      response = post(url,object)
      response._embedded.first.last.collect{|c|c.to_hash.merge('href' => c._links['self'].to_s) }
    end

    private

    [:get, :post, :put, :delete].each do |method_name|
      define_method method_name do |url,object=nil|
        api = Hyperclient.new(url) do |client|
          client.basic_auth(self.email, self.password)
        end
        begin
          if method_name == :get
            api.send("_#{method_name}")
          else
            api.send("_#{method_name}", object)
          end
        rescue => e
          if e.response[:status] == 401
            raise Agaon::Client::Error::NotAuthenticated
          else
            raise "ERROR: #{e.response[:body]}"
          end
        end
        api
      end
    end
  end
end