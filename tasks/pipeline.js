/**
 * grunt/pipeline.js
 *
 * The order in which your css, javascript, and template files should be
 * compiled and linked from your views and static HTML files.
 *
 * (Note that you can take advantage of Grunt-style wildcard/glob/splat expressions
 * for matching multiple files.)
 */



// CSS files to inject in order
//
// (if you're using LESS with the built-in default config, you'll want
//  to change `assets/styles/importer.less` instead.)


// Client-side javascript files to inject in order
// (uses Grunt-style wildcard/glob/splat expressions)


// Client-side HTML templates are injected using the sources below
// The ordering of these templates shouldn't matter.
// (uses Grunt-style wildcard/glob/splat expressions)
//
// By default, Sails uses JST templates and precompiles them into
// functions for you.  If you want to use jade, handlebars, dust, etc.,
// with the linker, no problem-- you'll just want to make sure the precompiled
// templates get spit out to the same file.  Be sure and check out `tasks/README.md`
// for information on customizing and installing new tasks.

var users = {
  home:{
    css:[
      'dependencies/**/*.css',
      'home.css'
    ],
    js:[
      'home/**/*.js'
    ],
    templates:[]
  },

  superuser:{
    css:[
      'dependencies/**/*.css',
      'common/**/*.css',
      'administrator.css'
    ],
    js:[
      'dependencies/sails.io.js',
      'dependencies/socket.io.js',
      'dependencies/angular.min.js',
      'dependencies/angular-aria.js',
      'dependencies/angular-resource.js',
      'dependencies/angular-animate.js',
      'dependencies/angular-material.js',
      'dependencies/**/*.js',
      'superuser/app.js',
      'superuser/**/*.js',
      'common/*.js',
      'common/**/*.js'



    ],
    templates:[
      'superuser/**/*.html'
    ]
  },
  administrator:{
    css:[
      'dependencies/**/*.css',
      'common/**/*.css',
      'administrator.css'
    ],
    js:[
      'dependencies/sails.io.js',
      'dependencies/socket.io.js',
      'dependencies/angular.min.js',
      'dependencies/angular-aria.js',
      'dependencies/angular-resource.js',
      'dependencies/angular-animate.js',
      'dependencies/angular-material.js',
      'dependencies/**/*.js',
      'administrator/app.js',
      'administrator/**/*.js',
      'common/*.js',
      'common/**/*.js'


    ],
    templates:[
      'administrator/**/*.html'
    ]
  }



}

for(var key in users){
  users[key].css = users[key].css.map(function(path){
    return ".tmp/public/styles/"+path;
  })
  users[key].js = users[key].js.map(function(path){
    return ".tmp/public/js/"+path;
  })
  users[key].templates = users[key].templates.map(function(path){
    return ".tmp/public/templates/"+path;
  })

}

// Prefix relative paths to source files so they point to the proper locations
// (i.e. where the other Grunt tasks spit them out, or in some cases, where
// they reside in the first place)

module.exports.users = users;
