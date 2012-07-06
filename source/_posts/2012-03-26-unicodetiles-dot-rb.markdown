---
layout: post
title: "unicodetiles.rb"
date: 2012-03-26 10:29
comments: true
categories: 
- 7DRL
- Ruby
---
After my miserable fail at the 7DRL 2012 I had the urge to get at least something get at least
something useful done. So I decided to port [unicodetiles.js](http://tapio.github.com/unicodetiles.js/), a lightweight, character based tile engine for JavaScript to Ruby. Luckily, tapio, the author of unicodetiles.js, made it easy for me to find a name for the ruby port and it shall henceforth be called [unicodetiles.rb](./projects/unicodetiles.html).

Porting the JavaScript code to Ruby went quite smoothly and I tried to 'rubify' the code wherever possible. I decided to implement the renderer on top of the gosu gem because it gave me all the tools I needed, especially the Gosu::Font class came in quite handy. The port is feature equivalent to the JavaScript version and the examples are exactly the same. I plan on adding some more features and use it for my next (7 Day?) Roguelike project and I will also release a gem in the next few days when everything is implemented and tested.

Unicodetiles.rb also works quite well as a replacement for ncurses, a popular framework for writing
fancy console applications used by a lot of roguelikes. The downside to ncurses is, that it is quite
hard (or even impossible) to get running under Windows which really hampers the popularity of some
roguelikes.
