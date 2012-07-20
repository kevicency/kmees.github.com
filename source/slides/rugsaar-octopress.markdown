---
layout: slides
title: "RUGSaar - Octopress"
date: 2012-07-20 09:53
sidebar: false
deck_theme: web-2.0
deck_transition: fade
deck_navigation: true
deck_status: true
deck_goto: true
deck_hash: true
deck_menu: true
deck_scale: false
---
{% img bg-bottom bg-right no-border /images/slides/octopress.png %}

{% slide %}
# Octopress
A blogging framework for hackers
{% endslide %}

{% slide %}
## Octopress
  * Framework zum Erstellen statischer Blogseiten
  * Basierend auf Jekyll
{% endslide %}

{% slide %}
## Jekyll
Generator fuer statische Websiten

Input:

  * Layout: HTML + Liquid Templates
  * Content: HTML/Markdown/Textile + Liquid Templates
  * Styling: (S)CSS + JavaScript (JQuery UI,...)

Output: Website

Engine hinter GitHub Pages
{% endslide %}

{% slide %}
## Jekyll - Probleme
  * Kein Default Layout
  * Kein Theming
  * Kein Scaffolding
  * Kein Syntax Highlighting
  * Kein Social

&rArr; Man fängt bei Null an.
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Layout
  * Semantisches HTML5 Template
  * Leicht Anpassbar durch Partials
  * Mobile Unterstützung
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Theming
  * Sehr gutes Default Theme
  * Kein CSS, sondern Compass + Sass
  * Automisches Erstellen der Screen.css
  * Automatische Neugenerierung
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Scaffolding
Rake Tasks für:

  * Installation (Orderstruktur)
  * Neue Posts
  * Neue Pages
  * Minifying (2.1)
  * uvm.
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Social
  * Twitter (Share + Latest Tweets)
  * Facebook Like / Google +1
  * Disqus Comments
  * Delicious
  * uvm.
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Blogging Plugins
  * Codeblocks (+ Pygments Syntax Highlighting)
  * Einbetten von
    * Gist
    * jsFiddle
    * Dateien im Filesystem
  * Quotes (Pullquote / Blockquote)
  * HTML5 Videos
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Deployment Skripte
  * GitHub Pages
  * Heroku
  * RSync
{% endslide %}

{% slide %}
## Octopress to the Rescue
### Sonstiges
  * Sidebar Widgets (Asides)
  * Sitemap Generator
  * Haml Support
  * Titlecase
{% endslide %}

{% slide %}
# Shut up and Code
(Demo)
{% endslide %}
