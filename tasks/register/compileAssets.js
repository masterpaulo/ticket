module.exports = function (grunt) {
	grunt.registerTask('compileAssets', [
		'clean:dev',
		'bower:dev',
		'jade:dev',
		'copy:dev',
		'jst:dev',
		'coffee:dev',
		'sass:dev'
	]);
};
