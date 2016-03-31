class Person < ActiveRecord::Base  
  composed_of :address, mapping: [%w(address_street street), 
                                  %w(address_city city), 
                                  %w(address_state state), 
                                  %w(address_zip zip)],
                        allow_nil: true
end
