/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html
 */
 var api = require("api-sdk");

var config = {
	host:"api.meditab.com",
	port: 80,
  // host:"192.168.9.2",
  // port: 3000,
	credentials:{"id":"55d3e4770c7f4dee47b668c8","key":"wwPY_j.NZRLa3onz6z5zzUy-UejpYPDaxTqYs85C"}
}

module.exports.bootstrap = function(cb) {

  // It's very important to trigger this callback method when you are finished
  // with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)


  api.initialize(config,function(data){
  	if(data.success){
  		cb();
  	}
  })
};
