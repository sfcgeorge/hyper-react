require "react/children"

module React
  module Component
    module DslInstanceMethods
      def children
        Children.new(`#{@native}.props.children`)
      end

      def params
        @props_wrapper
      end

      def props
        Hash.new(`#{@native}.props`)
      end

      def refs
        Hash.new(`#{@native}.refs`)
      end

      def state
        @state_wrapper ||= StateWrapper.new(@native, self)
      end
    end
  end
end
