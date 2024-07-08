require "spec_helper"
require "commonmarker"
require "grokdown/composing"

RSpec.describe Grokdown::Composing do
  before do
    described_module = described_class

    stub_const("CanComposeLinks", Class.new do
      extend described_module

      def add_link(object)
        object.parent = self
      end
    end)

    stub_const("Link", Class.new do
      attr_accessor :parent
    end)
  end

  it "can_compose? returns true if the instance can add the object's type" do
    expect(CanComposeLinks.can_compose?(Link.new)).to be_truthy
    expect(CanComposeLinks.new.can_compose?(Link.new)).to be_truthy
  end

  describe "#add_composable" do
    it "calls the object type's conventional composition_method" do
      link = Link.new
      can_compose_links = CanComposeLinks.new

      expect { can_compose_links.add_composable(link) }
        .to change(link, :parent)
        .from(nil).to(can_compose_links)
    end
  end
end
