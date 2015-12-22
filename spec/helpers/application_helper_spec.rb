require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe 'current_controller?' do
    before do
      allow(controller).to receive(:controller_name).and_return('foo')
      allow(controller).to receive(:class).and_return(double(name: 'Foo'))
    end

    it "returns true when controller matches argument" do
      expect(current_controller?(:foo)).to be_truthy
    end

    it "returns false when controller does not match argument" do
      expect(current_controller?(:bar)).to be_falsy
    end

    it "should take any number of arguments" do
      expect(current_controller?(:baz, :bar)).to be_falsy
      expect(current_controller?(:baz, :bar, :foo)).to be_truthy
    end

    it "should take namespace into account" do
      allow(controller).
        to receive(:class).
        and_return(double(name: 'Admin::Foo'))

      expect(current_controller?(:admin_foo)).to be_truthy
      expect(current_controller?(:foo)).to be_falsy
    end
  end

  describe 'current_action?' do
    before do
      allow(controller).to receive(:action_name).and_return('foo')
    end

    it "returns true when action matches argument" do
      expect(current_action?(:foo)).to be_truthy
    end

    it "returns false when action does not match argument" do
      expect(current_action?(:bar)).to be_falsy
    end

    it "should take any number of arguments" do
      expect(current_action?(:baz, :bar)).to be_falsy
      expect(current_action?(:baz, :bar, :foo)).to be_truthy
    end
  end
end
