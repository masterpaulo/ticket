var passport      = require('passport'),
  LocalStrategy   = require('passport-local').Strategy,
  passwordHash    = require('phpass').PasswordHash,
  ncrypt          = new passwordHash(),
  checkCompany    = ['meditab.com', 'suiterx.com', 'intellmed.ph'],
  api             = require( "api-sdk"),
  USER            = new api.model("appuser");

passport.serializeUser(function (user, done) {
  done(null, user);
});

passport.deserializeUser(function (user, done) {
  USER.show(user.appuser)
  .exec(function(err,user){
    done(err,user);
  })
});

passport.use(new LocalStrategy(
  {
    usernameField: 'email',
    passwordField: 'password'
  },
  function(email, password, done) {
    var data;
    data = {
      email: email,
      password: password,
      strategy: "local"
    }
    api.login(data, function(err, res){
      if(err){
        return done(err,null);
      }else{
        if(!res.error){
          return done( null,res);
        }else{
          return done( res,null);
        }
      }
    })
  })
);

module.exports = {
  http: {
    customMiddleware: function (app) {
      app.use(passport.initialize());
      app.use(passport.session());
    }
  }
};