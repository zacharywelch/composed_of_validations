module ComposedOfValidations
  module Aggregations
    module ValueObject
      extend ActiveSupport::Concern

      included do 
        if included_modules.include? ::ActiveModel::Validations
          def freeze
            self.valid?
            super
          end

          def valid?(context = nil)
            unless self.frozen?
               current_context, self.validation_context = validation_context, context
               errors.clear
               @valid = run_validations!
             else
               @valid
             end
          ensure
            self.validation_context = current_context unless self.frozen?
          end
        else
          def valid?(_)
            true
          end
        end
      end
    end
  end
end
