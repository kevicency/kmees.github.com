---
layout: post
title: "HTML Presentations with Octopress and deck.js - Part II"
date: 2012-07-16 14:02
comments: true
external-url: 
categories: 
- Octopress
- deck.js
---
In my [last post](/blog/2012/07/07/html-presentations-with-octopress-and-deck-dot-js/) I demonstrated how to create HTML presentations with [deck.js](http://http://imakewebthings.com/deck.js/)
and hosting them inside your Octopress blog. While the *'client-side'* is basically finished, the
*'backend'* still needs some work because

  * we can't use markdown to write the slides
  * we must create a new slidedeck by hand

The first problem can be solved by creating a custom `Liquid::Block` for slides and the second
problem can be solved by creating a small rake task that basically works the same as the `new_post`
task.

<!-- more -->

## A Liquid::Block for Slides
Currently, when writing slides, we have to use HTML because Markdown inside HTML block tags like
`<div></div>` will be ignored by the Markdown processor. To fix this problem we will create a custom
`Liquid::Block` that wraps its content inside a slide div. With the help of the `Liquid::Block` we
can write a slide like this:
```
{% slide first %}
  ## Title
  content
{% endslide $}
```
This will then compile to the following HTML:
``` html
<div class='slide' id='first'>
  <h2>Title</h2>
  content
</div>
```

### Implementation
Implementing the `Liquid::Block` is actually quite easy. First, we create a file `slide.rb` in `./plugins`
with the following content:
``` ruby
module Jekyll
  class Slide < Liquid::Block
  end
end

Liquid::Template.register_tag('slide', Jekyll::Slide)
```
This creates a class for our custom `Liquid::Block` and registers it as a tag in the Liquid engine. This is enough to use
the tag but nothing will be generated yet. Next we will override the `initialize` method and parse the id of the slide.
``` ruby
class Slide < Liquid::Block
  SlideId = /(\w+)/

  def initialize(tag_name, markup, tokens)
    super
    @id = nil
    if markup.strip =~ SlideId
      @id = $1
    end
  end
end
```
Since we only have to parse one argument, the id, this is fairly simple. The `markup` variable contains everything that comes
after `slide` in the opening brackets, i.e. `{% slide markup is this part %}`. The regex we use to parse the id matches the 
first word and ignores everything thereafter.

The next step is to override the `render` method that converts everything inside our slide block
from Markdown to HTML and wraps it with a slide div.
``` ruby
require 'rdiscount'

module Jekyll
  class Slide < Liquid::Block
    # ...
    def render(context)
      id_tag = " id='#{@id}'" unless @id.nil?
      content = RDiscount.new(super.strip, :smart).to_html.chop
      "<div class='slide'#{id_tag}>#{content}</div>".strip
    end
  end
end
```
The only interesting part here is the usage of `super`. We call `super` here to get the content of
our block tag and run it through *RDiscount* to convert it to HTML.

And that is all we need for our custom slide block !

## A Rake task for Slides
The will be even easier than creating the `Liquid::Block`. First we define two new variables in the
`Rakefile` which are pretty self-explanatory
``` ruby
slides_dir      = "slides"    # directory for slides`
new_slides_ext  = "markdown"  # default new slides file extension when using the new_slides task
```
For the task itself we copy the existing `:new_post` task and replace the `posts_dir` with
`slides_dir`, `new_post_ext` with `new_slides_ext` and adjust all the messages. We will also add all
the deck.js options to the *YAML Front Matter* and change the layout from `post` to `slides`. The
complete slides task looks like this:
``` ruby
# usage rake new_slides[my-cool-slides] or rake new_post['my cool slides'] or rake new_post (defaults to "new-slides")
desc "Create new slides in #{source_dir}/#{slides_dir}"
task :new_slides, :title do |t, args|
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your slides: ")
  end
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  mkdir_p "#{source_dir}/#{slides_dir}"
  filename = "#{source_dir}/#{slides_dir}/#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new slides: #{filename}"
  open(filename, 'w') do |slides|
    slides.puts "---"
    slides.puts "layout: slides"
    slides.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    slides.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    slides.puts "sidebar: false"
    slides.puts "deck_theme: web-2.0"
    slides.puts "deck_transition: fade"
    slides.puts "deck_navigation: true"
    slides.puts "deck_status: true"
    slides.puts "deck_goto: true"
    slides.puts "deck_hash: true"
    slides.puts "deck_menu: true"
    slides.puts "deck_scale: true"
    slides.puts "---"
    slides.puts "{% slide first %}"
    slides.puts "{% endslide %}"
  end
end
```


