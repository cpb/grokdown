module Grokdown
  module Composing
    def self.extended(base) = base.include(InstanceMethods)

    def can_compose?(object) = public_instance_methods.include?(composition_method(object))

    def composition_method(object)
      :"add_#{object.class.name.downcase}" if object.class.name
    end

    module InstanceMethods
      def can_compose?(object) = self.class.can_compose?(object)

      def composition_method(object) = self.class.composition_method(object)

      def add_composable(object)
        public_send(composition_method(object), object) if can_compose?(object)
      end
    end
  end
end
