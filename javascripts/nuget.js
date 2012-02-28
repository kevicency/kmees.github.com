var nuget = (function(){
  function render(target, packages){
    var i = 0, fragment = '', t = $(target)[0];

    for(i = 0; i < packages.length; i++) {
      fragment += '<li><a href="'+packages[i].url+'">'+packages[i].name+'</a><p>'+packages[i].description+'</p></li>';
    }
    t.innerHTML = fragment;
  }
  return {
    showPackages: function(options){
      $.ajax({
        url: "http://nuget.org/profiles/"+options.user,
        type: "GET",
        dataType: "html",
        error: function (err) { $(options.target + ' li.loading').addClass('error').text("Error loading feed"); },
        success: function(data) {
          var response = $("<div />").html(data);
          var packages = [];

          response.find($('.package > .main')).each(function(i,pkg) {
            var package = {
              url:pkg.find("h1 > a").attr("href"),
              name:pkg.find("h1 > a").html(),
              description:pkg.find("p").html().trim()
            };
          });

          packages.push(package);

          if (options.count) { packages.splice(options.count); }
          render(options.target, packages);
        }
      });
    }
  };
})();
