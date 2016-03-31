require 'spec_helper'

describe ComposedOfValidations do

  subject(:person) do 
    Person.create name: 'Tobias', 
                  address_street: '123 Sesame St', 
                  address_city: 'Atlanta', 
                  address_state: 'GA', 
                  address_zip: '30092'
  end

  describe '#address' do
    it 'maps address' do
      expect(person.address).to_not be_nil
      expect(person.address).to be_an Address
      expect(person.address.city).to eq 'Atlanta'
    end
  end

  describe '#address=' do
    
    let(:new_address) do
      Address.new 'New York Street', 'New York City', 'NY', '10001'
    end

    before { person.address = new_address }
      
    it 'maps new address' do
      expect(person.address).to_not be_nil
      expect(person.address).to be_an Address
      expect(person.address.city).to eq 'New York City'
    end

    it 'supports valid?' do
      expect { person.address.valid? }.to_not raise_error
      expect(person.address).to be_valid
    end

    context 'when address is invalid' do 
      let(:invalid_address) do
        Address.new 'New York Street', nil, 'NY', '10001'
      end

      before { person.address = invalid_address }

      specify { expect(person.address).to_not be_valid }
    end

    context 'when autosave is disabled' do
      it 'does not save to database' do
        expect(person).to receive(:save!).never
        person.address = nil
      end
    end

    context 'when autosave is enabled' do
      before do
        Person.composed_of :address, mapping: [%w(address_street street), 
                                               %w(address_city city), 
                                               %w(address_state state), 
                                               %w(address_zip zip)],
                                     allow_nil: true,
                                     autosave: true
      end

      it 'saves to database' do
        expect(person).to receive(:save!).once
        person.address = nil
      end
    end
  end
end
