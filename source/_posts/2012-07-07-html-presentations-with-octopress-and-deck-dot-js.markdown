---
layout: post
title: "HTML Presentations with Octopress and deck.js"
date: 2012-07-07 01:39
comments: true
external-url: 
categories: 
- octopress
- deck.js
---
So, I'm about the give a short talk about [Octopress](http://www.octopress.org) at the next RUGSaar
(Ruby Usergroup Saar) meeting. Since I will probably need at least a bunch of slides I thought about
the way of presenting them. PowerPoint (or similar) would be the natural choice but it isn't very
hacker...ish and since Octopress is "a blogging framework for hackers" we surely can do better.

I've recently read about [various HTML5 based web presentation frameworks](http://www.sitepoint.com/5-free-html5-presentation-systems/#fbid=1hmB1c0Eihu)
and wanted to try them out but didn't have an opportunity 'til now. I'll go with [deck.js](http://http://imakewebthings.com/deck.js/)
for no specific reason other than that it seems easy to show the slides inside an existing webpage
or blog.
So I'll be giving a talk about Octopress with slides hosted inside my own Octopress blog !
<!-- more -->

_I have linked most source files instead of embedding the source directly because the liquid tags in
html pages won't render correctly_

## The slides layout
Okay, where to start? From inspecting the [demo presentation](http://imakewebthings.com/deck.js/introduction/) and having a look at the [source](https://github.com/imakewebthings/deck.js),
we need a custom layout for our slides that takes care of the following tasks.

  * Loading all the css files required by deck.js in the head.
  * Loading all the js files required by deck.js in the body and initializing the slidedeck.
    Extensions should be activatable per slidedeck.
  * Loading a theme and transition effect defined by each slidedeck

Since we want to host the slides inside our blog, the slides layout should have the default
octopress layout as its parent, similair to the layout for posts and pages.

### Loading the CSS
A quick peek at the deck.js source shows that the author kindly included the SASS files from which
the CSS was created. This means that we can easily add those and compile them into our `screen.css`
instead of loading them all separately. We will start by creating a `sass/custom/deck.js/` folder
and copying all the `deck.*.sccs` files into it. We should also rename them to `_deck.*.scss` to
match the SASS naming convention for partial files. Then we'll create `sass/custom/deck.js.scss`
that imports all the files from the deck.js subfolder and finally import that file at the top of
the `_styles.scss`.

{% include_code ../../../sass/custom/_deck.js.scss %}

### Loading the JS
This part will be rather easy. We will use the [source/_layouts/page.html](https://github.com/kmees/kmees.github.com/tree/source/source/_layouts/page.html) as a template for our
slides layout. We can basically keep it as is and only change the page secific stuff like 
`custom/page-meta.html` with `custom/slides-meta.html`. I also changed the `<header/>` tag to a 
title slide that shows the title of the slidedeck and some other minor
stuff. Anyway, the important part is to add the deck.js stuff directly below the `content` Liquid
tag and add a `.deck-container` div as a subelement of `<article/>`.
To support deactivation of specific extensions for each slidedeck, we will wrap the markup for each
extension with a `{{ unless page.deck_feature == false }}` Liquid block. The properties of the page
can be set in the *YAML Front Matter* which I'll cover in a minute. Here's the source of the
finished [slides
layout](https://github.com/kmees/kmees.github.com/tree/source/source/_layouts/slides.html).

### Support for Themes and Transition Effects
We will also use page properties for loading a specific theme on transition effect. The markup will
reside in [source/_includes/custom/head.html](https://github.com/kmees/kmees.github.com/tree/source/source/_inlucudes/custom/head.html) and is quite simple. It just loads the css file for
the theme and transition effect with the name provided by `page.deck_theme` and
`page.deck_transition` respectively.

## Creating the Slides
With the layout in place, we can now actually start to work on the slides. We'll create a `source/slides` folder and
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
