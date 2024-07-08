module Grokdown
  module Composing
    def self.extended(base) = base.include(InstanceMethods)

    def can_compose?(object) = public_instance_methods.include?(composition_method(object))

    def composition_method(object)
      :"add_#{object.class.name.gsub("::", "_").gsub(/([A-Z])(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) { ($1 || $2) << "_" }.downcase}" if object.class.name
    end

    module InstanceMethods
      def can_compose?(object) = self.class.can_compose?(object)

      def composition_method(object) = self.class.composition_method(object)

      def add_composable(object)
        public_send(composition_method(object), object)
      end
    end
  end
end
