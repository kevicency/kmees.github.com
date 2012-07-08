---
layout: post
title: "HTML Presentations with Octopress and deck.js"
date: 2012-07-07 01:39
comments: true
external-url: 
categories: 
---
So, I'm about the give a short talk about [Octopress](http://www.octopress.org) at the next RUGSaar
(Ruby Usergroup Saar) meeting. Since I will probably need at least a bunch of slides I thought about
the way of presenting them. PowerPoint (or similar) would be the natural choice but it isn't very
hacker...ish and since Octopress is "a blogging framework for hackers" we surely can do better.

I've recently read about [various HTML5 based web presentation frameworks](http://www.sitepoint.com/5-free-html5-presentation-systems/#fbid=1hmB1c0Eihu)
and wanted to try them out but didn't have an opportunity 'til now. I'll go with [deck.js](http://http://imakewebthings.com/deck.js/)
for no specific reason other than that it seems easy to show the slides inside an existing webpage
  or blog.
So I'll be giving a talk about Octopress with slides hosted inside my own Octopress blog.

Now that souds hackerish !
<!-- more -->
## Creating a Slidedeck Layout
Okay, where to start? From inspecting the [demo presentation]() and having a look at the [source](),
we need a custom layout page for our slides. We need to load the css files from *deck.js* in the
head of the layout page. We also need to load/execute some JavaScript in the body of the page. To keep
everything **DRY**, this will also be handled by the layout page. This way, the
file with the presentation needs to focus solely on the content of the presentation and the rest is handled
by the framework.

We start by customizing the head file of the layout. We copy the `source/_includes/head.html` and
name it `slidedeck_head.html`. We can keep everything as it is and just add the deck.js specific
markup **before** the link tag to our `screen.css`. We need to include it before the `screen.css`
such that we can override some default deck.js styles.

Next, we copy `source/_layouts/defaut.html`, which containts the default layout, and call it `slidedeck.html`.
We can basically keep all of the markup and just add all the deck.js specific code to the innermost div, 
just underneath the content placeholder. Deck.js requires a `.deck-container` which wraps the slide divs, 
so we'll add that class to the `#content` div. We also replace the inclusion oh `head.html` with our custom 
`slidedeck_head.html`. If you don't want to use a specific deck.js extension, just remove the
according script tag from the layout file.

Here's the source of the two layout files.
{% include_code slidedeck_head.html %}
{% include_code slidedeck.html %}

## Creating the Slides

Alright, now we can actually start to work on the slides. We'll create a `source/slides` folder and
add `demo.html` inside. To keep it simple, we'll add just two slides.

{% include_code ../../slides/demo.html %}

Note the `layout: slidedeck` in the *YAML Front Matter*. This tells octoblog to load our custom
slidedeck layout. And that's basically it. You can see the result [here](/slides/demo.html).

## ToDos

Although everything seems to work, there is still work to do. The most important thing is, that we
can't use *Markdown* the create write out slides because Markdown written inside HTML block tags
will be ignored by the Markdown processor. This is not a bug, but working as intended. It would
also be nice to have a *Rake task* for generating the slidedeck stub, similar to the task that
generates a post stub. But this will all be part of my next post.
