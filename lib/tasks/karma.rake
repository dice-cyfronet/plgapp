namespace :karma do
	desc 'Runs karma tests offline'
	task :test => :environment do
		sh './node_modules/karma/bin/karma start config/karma.conf.js  --single-run'
	end
	
	desc 'Runs karma tests interactively'
	task :run => :environment do
		sh './node_modules/karma/bin/karma start config/karma.conf.js'
	end
end