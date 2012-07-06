---
layout: post
title: "Bypassing the Google Feed API Cache"
date: 2012-03-29 23:22
comments: true
categories: 
- Octopress
- NuGet
---
{% img center /images/posts/google_feed_api_meme.png %}

I noticed recently that the download count of the packages in my [NuGet Aside](https://github.com/kmees/Octopress-NuGet-Aside) didn't update properly. As I [mentioned earlier](/blog/2012/02/29/nuget-aside-for-octopress/), I use the [Google Feed API](https://developers.google.com/feed/) to get the data from the NuGet Gallery feed of an author. This indicrection is needed because the NuGet Gallery API doesn't support the **jsonp** response type (yet). Anyway, the problem is that Google caches the feeds heavily and only adds new entries but doesn't update existing ones. This means that the packages keep their download count of the first request.
<!--more-->
After some experiments, I concluded that the caching behavior is solely based on the feed URL and modifying the URL in a way that it 'looks' different but still returns the same data circumvents the cache. I created a salt function that returns a large number based on the current time which I just append to the URL as an additional query parameter (that gets ignored by the API).
``` javascript
function salt() {
  var now = new Date();
  var saltDate = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  return saltDate.getTime();
}
```
As you may notice, the function returns the same number throughout the whole day. This way, the feed can still be cached but the data gets updated every day which is a good compromise !
