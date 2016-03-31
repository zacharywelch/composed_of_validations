# composed_of_validations

`ActiveModel::Validations` support for [composed_of](http://apidock.com/rails/ActiveRecord/Aggregations/ClassMethods/composed_of)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'composed_of_validations', git: 'git@cagit.careerbuilder.com:zwelch/composed_of_validations.git'
```

And then execute:

    $ bundle

## Usage

composed_of_validations patches ActiveRecord `composed_of` with support for `ActiveModel::Validations`. See issue [1513](https://github.com/rails/rails/issues/1513) for more background.

If we want to represent address attributes as a value object
```ruby
class Person < ActiveRecord::Base
  composed_of :address, mapping: [%w(address_street street), 
                                  %w(address_city city), 
                                  %w(address_state state), 
                                  %w(address_zip zip)],
                        allow_nil: true
end
```

We can define our value object with validations
```ruby
class Address
  include ActiveModel::Validations
  attr_reader :street, :city, :state, :zip
  
  def initialize(street, city, state, zip)
    @street = street
    @city = city
    @state = state
    @zip = zip
  end

  validates_presence_of :street, :city, :state, :zip
end
```

And receive support similar to `ActiveRecord`.
```ruby
> person = Person.first
 => #<Person id: 1, name: "Tobias", address_street: "123 Sesame St", address_city: "Atlanta", address_state: "GA", address_zip: "30092"> 

> person.address
 => #<Address:0x007fc6b4e34ea0 @street="123 Sesame St", @city="Atlanta", @state="GA", @zip="30092"> 

> person.address = Address.new('New York Street', nil, 'NY', '10001')
> person.address.valid? 
 => false
> person.address.errors.full_messages
 => ["City can't be blank"]
```

composed_of_validations adds the `autosave` option to automatically save when a new value is assigned. 

```ruby
class Person < ActiveRecord::Base
  composed_of :address, mapping: [%w(address_street street), 
                                  %w(address_city city), 
                                  %w(address_state state), 
                                  %w(address_zip zip)],
                        allow_nil: true,
                        autosave: true
end

> person.persisted? 
 => false
> person.address = nil
 => nil
> person.address.persisted? 
 => true
```

## Contributing

1. Fork it ( https://cagit.careerbuilder.com/zwelch/composed_of_validations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
