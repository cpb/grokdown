require "spec_helper"
require "commonmarker"
require "grokdown/never_composable"

RSpec.describe Grokdown::NeverComposable do
  subject do
    _doc, _paragraph, text = *CommonMarker.render_doc("text").walk

    described_class.new(text)
  end

  it { is_expected.to_not be_can_compose }
  it { is_expected.to_not be_can_compose(subject) }
  it { is_expected.to have_attributes(type: :text, first_child: nil) }
  it { is_expected.to eq(described_class.new(CommonMarker.render_doc("text").walk.to_a.last)) }
end
