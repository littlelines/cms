module PushType
  module Customizable
    extend ActiveSupport::Concern

    included do
      after_initialize :initialize_fields
    end

    def fields
      @fields ||= {}
    end

    # Overrides ActiveRecord::Base#attribute_for_inspect
    # Minimises field_store value for more readable inspect
    def attribute_for_inspect(attr_name)
      if attr_name.to_s == 'field_store'
        fields.keys.inspect
      else
        super
      end
    end

    private

    def initialize_fields
      all_nested_fields.keys.each do |key|
        f = initialized_field(key)
        if block = f.class.init_block
          block.call(self, f)
        end
      end
    end

    def all_nested_fields
      all_fields = self.class.fields
      self.class.descendants.each do |klass|
        all_fields.merge!(klass.fields)
      end
      all_fields
    end

    def initialized_field(key)
      fields[key] ||= begin
        klass, opts, blk = self.class.fields[key]
        klass.new(key, self, opts, &blk)
      end
    end

    module ClassMethods

      attr_reader :fields

      def fields
        @fields ||= {}
      end

      def field(name, *args, &blk)
        raise ArgumentError if args.size > 2
        kind, opts = case args.size
          when 2 then args
          when 1 then args[0].is_a?(Hash) ? args.insert(0, :string) : args.insert(-1, {})
          else        [ :string, {} ]
        end

        # Store field type and set accessor
        fields[name] = [ field_type(kind), opts, blk ].compact
        store_accessor :field_store, name

        # Set inline validates
        validates name, opts[:validates] if opts[:validates]

        # Override setter accessor
        define_method "#{ name }=".to_sym do |val|
          f = initialized_field(name)
          super f.primitive.to_json(val)
        end

        # Override getter accessor
        define_method name do
          self.fields[name].value
        end

        if block = fields[name][0].def_block
          block.call(self, name, fields[name][0])
        end
      end

      protected

      def field_type(kind)
        begin
          "push_type/#{ kind }_field".camelize.constantize
        rescue NameError
          "#{ kind }_field".camelize.constantize
        end
      end

    end
  end
end
