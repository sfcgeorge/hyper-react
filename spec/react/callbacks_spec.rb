require 'spec_helper'

if opal?
describe React::Callbacks do
  it 'defines callback' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      before_dinner :wash_hand

      def wash_hand
      end
    end

    instance = Foo.new
    expect(instance).to receive(:wash_hand)
    instance.run_callback(:before_dinner)
  end

  it 'defines multiple callbacks' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner

      before_dinner :wash_hand, :turn_off_laptop

      def wash_hand;end

      def turn_off_laptop;end
    end

    instance = Foo.new
    expect(instance).to receive(:wash_hand)
    expect(instance).to receive(:turn_off_laptop)
    instance.run_callback(:before_dinner)
  end

  context 'using Hyperloop::Context.reset!' do
    after(:all) do
      Hyperloop::Context.instance_variable_set(:@context, nil)
    end
    it 'clears callbacks on Hyperloop::Context.reset!' do
      Hyperloop::Context.reset!
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Callbacks
        define_callback :before_dinner

        before_dinner :wash_hand, :turn_off_laptop

        def wash_hands;end

        def turn_off_laptop;end
      end
      instance = Foo.new
      expect(instance).to receive(:wash_hand).once
      expect(instance).not_to receive(:turn_off_laptop)

      Hyperloop::Context.reset!

      instance.run_callback(:before_dinner)
      Foo.class_eval do
        before_dinner :wash_hand
      end
      instance.run_callback(:before_dinner)
    end
  end # moved elswhere cause its just hard to get anything to work in this environment

  it 'defines block callback' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      attr_accessor :a
      attr_accessor :b

      define_callback :before_dinner

      before_dinner do
        self.a = 10
      end
      before_dinner do
        self.b = 20
      end
    end

    foo = Foo.new
    foo.run_callback(:before_dinner)
    expect(foo.a).to eq(10)
    expect(foo.b).to eq(20)
  end

  it 'defines multiple callback group' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      define_callback :after_dinner
      attr_accessor :a

      before_dinner do
        self.a = 10
      end
    end

    foo = Foo.new
    foo.run_callback(:before_dinner)
    foo.run_callback(:after_dinner)

    expect(foo.a).to eq(10)
  end

  it 'receives args as callback' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      define_callback :after_dinner

      attr_accessor :lorem

      before_dinner do |a, b|
        self.lorem  = "#{a}-#{b}"
      end

      after_dinner :eat_ice_cream
      def eat_ice_cream(a,b,c);  end
    end

    foo = Foo.new
    expect(foo).to receive(:eat_ice_cream).with(4,5,6)
    foo.run_callback(:before_dinner, 1, 2)
    foo.run_callback(:after_dinner, 4, 5, 6)
    expect(foo.lorem).to eq('1-2')
  end
end
end
