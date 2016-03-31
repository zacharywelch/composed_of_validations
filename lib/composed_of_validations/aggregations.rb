require 'active_record'
require 'composed_of_validations/aggregations/value_object'

module ComposedOfValidations
  module Aggregations
    extend ActiveSupport::Concern

    module ClassMethods

      # Adds reader and writer methods for manipulating a value object:
      # <tt>composed_of :address</tt> adds <tt>address</tt> and <tt>address=(new_address)</tt> methods.
      #
      # Options are:
      # * <tt>:class_name</tt> - Specifies the class name of the association. Use it only if that name
      #   can't be inferred from the part id. So <tt>composed_of :address</tt> will by default be linked
      #   to the Address class, but if the real class name is CompanyAddress, you'll have to specify it
      #   with this option.
      # * <tt>:mapping</tt> - Specifies the mapping of entity attributes to attributes of the value
      #   object. Each mapping is represented as an array where the first item is the name of the
      #   entity attribute and the second item is the name of the attribute in the value object. The
      #   order in which mappings are defined determines the order in which attributes are sent to the
      #   value class constructor.
      # * <tt>:allow_nil</tt> - Specifies that the value object will not be instantiated when all mapped
      #   attributes are +nil+. Setting the value object to +nil+ has the effect of writing +nil+ to all
      #   mapped attributes.
      #   This defaults to +false+.
      # * <tt>:constructor</tt> - A symbol specifying the name of the constructor method or a Proc that
      #   is called to initialize the value object. The constructor is passed all of the mapped attributes,
      #   in the order that they are defined in the <tt>:mapping option</tt>, as arguments and uses them
      #   to instantiate a <tt>:class_name</tt> object.
      #   The default is <tt>:new</tt>.
      # * <tt>:converter</tt> - A symbol specifying the name of a class method of <tt>:class_name</tt>
      #   or a Proc that is called when a new value is assigned to the value object. The converter is
      #   passed the single value that is used in the assignment and is only called if the new value is
      #   not an instance of <tt>:class_name</tt>. If <tt>:allow_nil</tt> is set to true, the converter
      #   can return nil to skip the assignment.
      #
      # Option examples:
      #   composed_of :temperature, mapping: %w(reading celsius)
      #   composed_of :balance, class_name: "Money", mapping: %w(balance amount),
      #                         converter: Proc.new { |balance| balance.to_money }
      #   composed_of :address, mapping: [ %w(address_street street), %w(address_city city) ]
      #   composed_of :gps_location
      #   composed_of :gps_location, allow_nil: true
      #   composed_of :ip_address,
      #               class_name: 'IPAddr',
      #               mapping: %w(ip to_i),
      #               constructor: Proc.new { |ip| IPAddr.new(ip, Socket::AF_INET) },
      #               converter: Proc.new { |ip| ip.is_a?(Integer) ? IPAddr.new(ip, Socket::AF_INET) : IPAddr.new(ip.to_s) }
      #
      def composed_of(part_id, options = {})
        options.assert_valid_keys(:class_name, :mapping, :allow_nil, :constructor, :converter, :autosave)

        name        = part_id.id2name
        class_name  = options[:class_name]  || name.camelize
        mapping     = options[:mapping]     || [ name, name ]
        mapping     = [ mapping ] unless mapping.first.is_a?(Array)
        allow_nil   = options[:allow_nil]   || false
        constructor = options[:constructor] || :new
        converter   = options[:converter]
        autosave    = options[:autosave]    || false

        reader_method(name, class_name, mapping, allow_nil, constructor)
        writer_method(name, class_name, mapping, allow_nil, converter, autosave)

        reflection = ::ActiveRecord::Reflection.create(:composed_of, part_id, nil, options, self)
        ::ActiveRecord::Reflection.add_aggregate_reflection self, part_id, reflection
      end

      private
      
      def reader_method(name, class_name, mapping, allow_nil, constructor)
        define_method(name) do
          if @aggregation_cache[name].nil? && (!allow_nil || mapping.any? {|key, _| !_read_attribute(key).nil? })
            attrs = mapping.collect {|key, _| _read_attribute(key)}
            object = constructor.respond_to?(:call) ?
              constructor.call(*attrs) :
              class_name.constantize.send(constructor, *attrs)
            object.class_eval { include ValueObject }
            @aggregation_cache[name] = object
          end
          @aggregation_cache[name]
        end
      end

      def writer_method(name, class_name, mapping, allow_nil, converter, autosave)
        define_method("#{name}=") do |part|
          klass = class_name.constantize
          if part.is_a?(Hash)
            part = klass.new(*part.values)
          end

          unless part.is_a?(klass) || converter.nil? || part.nil?
            part = converter.respond_to?(:call) ? converter.call(part) : klass.send(converter, part)
          end

          if part.nil? && allow_nil
            mapping.each { |key, _| self[key] = nil }
            @aggregation_cache[name] = nil
          else
            mapping.each { |key, value| self[key] = part.send(value) }
            part.class_eval { include ValueObject }
            @aggregation_cache[name] = part.freeze
          end
          save! if autosave && (part.nil? || part.valid?)
        end
      end    
    end
  end
end

ActiveRecord::Base.send :include, ComposedOfValidations::Aggregations