module.exports = function(config) {
	config.set({
		basePath: '../',
		frameworks: ['jasmine-ajax', 'jasmine'],
		browsers: ['PhantomJS'],
		files: [
			'public/plgapp/jquery/1.11.3/jquery.min.js',
			'public/plgapp/plgapp.js',
			'public/plgapp/datanet.js',
			'spec/karma/*.js'
		],
		plugins: [
		    'karma-jasmine-ajax',
		    'karma-jasmine',
		    'karma-phantomjs-launcher'
		]
	});
};