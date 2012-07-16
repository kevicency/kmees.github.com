require 'rdiscount'

module Jekyll
  class Slide < Liquid::Block
    SlideId = /(\w+)/

    def initialize(tag_name, markup, tokens)
      super
      @id = nil
      if markup.strip =~ SlideId
        @id = $1
      end
    end

    def render(context)
      id_tag = " id='#{@id}'" unless @id.nil?
      content = RDiscount.new(super.strip, :smart).to_html.chop
      "<div class='slide'#{id_tag}>#{content}</div>".strip
    end
  end
end

Liquid::Template.register_tag('slide', Jekyll::Slide)
