require 'liquid'
require './plugins/slide.rb'
require './plugins/image_tag.rb'

describe Jekyll::Slide do
  let(:input) { "{% slide %}{% endslide %}" }
  subject do
    Liquid::Template.parse(input).render()
  end

  describe "converting an empty slide tag" do
    it { should == "<div class='slide'></div>" }
  end

  describe "converting a slide tag with id" do
    let(:input) { "{% slide foo %}{% endslide %}" }

    it { should == "<div class='slide' id='foo'></div>" }
  end

  describe "converting a slide tag with markdown content" do
    let(:input) { "{% slide %}*foo*{% endslide %}" }

    it { should == "<div class='slide'><p><em>foo</em></p></div>" }
  end

  describe "converting a slide tag within a slide tag" do
    let(:input) { "{% slide %}{% slide %}{% endslide %}{% endslide %}" }

    it { should == "<div class='slide'><div class='slide'></div>\n</div>" }
  end

  describe "converting a slide tag with another liquid tag inside" do
    let(:input) { "{% slide %}{% img http://foo %}{% endslide %}" }

    it { should == "<div class='slide'><p><img class=\"\" src=\"http://foo\"></p></div>" }
  end

  describe "converting a slide tag with another liquid tag inside" do
    let(:input) { "{% slide %}\n# Foo\n{% img http://foo %}{% endslide %}" }

    it { should == "<div class='slide'><h1>Foo</h1>\n\n<p><img class=\"\" src=\"http://foo\"></p></div>" }
  end
end

