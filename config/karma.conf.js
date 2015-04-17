module.exports = function(config) {
	config.set({
		basePath: '../',
		frameworks: ['jasmine'],
		browsers: ['PhantomJS'],
		files: [
		    'public/plgapp/datanet.js',
		    'spec/karma/*.js'
		],
		frameworks: ['jasmine'],
		plugins: [
		    'karma-jasmine',
		    'karma-phantomjs-launcher'
		]
	});
};