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
