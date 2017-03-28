# Agaon

Ruby API wrapper for Fiken. See https://fiken.no/api/doc/ for information about the API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'agaon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install agaon

## Usage

### Authentication

```ruby
fiken = Agaon::Client.new( username, password )
```

This will allow you to only list companies connected to your user account.

To access data in each company you need to specify a company for the Agaon client.

```ruby
fiken = Agaon::Client.new( username, password, company_href )
```

### Endpoints

#### Companies

```ruby
companies = fiken.companies
```

#### Sales, Contacts, Accounts, Invoices

Using examples for the contacts endpoint.

List:
```ruby
client.contacts
```
Get:
```ruby
client.get_contact(contact_href)
```
Create:
```ruby
client.contact(contact_attributes)
```
Update:
```ruby
client.contact(contact_href,contact_attributes)
```

#### Create Invoice, Document Sending Service, Create General Journal Entry Service, Search

Using example for the create invoice endpoint.

Action:
```ruby
client.create_invoice(invoice_attributes)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/espen/agaon.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

