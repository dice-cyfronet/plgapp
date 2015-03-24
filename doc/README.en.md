### Application development

*plgapp* supports development mode of its applications to make sure testing of the changes introduced to your code does not interfere with the production instance. The development instance of any application is always available under the `{application-subdomain}-dev.app.plgrid.pl` address and is available only to users who are logged in to the *plgapp* platform. Let's go over a list of steps necessary to create a new application with *plgapp*.

1. Login to *plgapp* with the PL-Grid OpenID server (use the *PL-GRID LOGIN* link located in the page header). You need to have the *plgapp* service activated in the PL-Grid portal.

1. Switch to the *MY APPLICATIONS* tab and use the *ADD NEW* button to create a new application. You need to provide the following data:

	**Name** - this is the application's friendly name used in the application list,
	
	**Subdomain** - subdomain is used to create your application's URL which will have the following form: `https://{application-subdomain}.app.plgrid.pl`,
	
	**Login page text** - provided text is displayed on the login page of your application; you can use the [markdown notation](http://daringfireball.net/projects/markdown/) to format the text.
	
	After clicking the *CREATE* button your application is ready to be developed and already integrated (only the development mode) with the PL-Grid OpenID server. The provided values can be modified at any time by using the *EDIT* button in the application's panel. You can now learn about synchronizing development files in the section below.

#### Development file synchronization with Dropbox

To start the development of your application you need to provide us with the files executed in the browser (these will be HTML, CSS and JavaScript files in most cases). Remember that *plgapp* applications are run in the user's browser and that any interaction with the computing infrastructure is done with the help of JavaScript libraries (in most cases the set of libraries provided by the platform should suffice). In order to automate the process of transmitting your application's files to the platform Dropbox was employed to do just that. Changed to the files edited on your computer are picked up and transfered to the platform to take effect in the browsed application. Here is a list of steps required to accomplish a full development cycle:

1. Let's assume you have just created a new application and want to create the first page a user sees after they log in. Go to your application's panel and switch to the *DEPLOY* tab where you should pick the *DROPBOX* deployment option. Below you will see a *CONNECT TO DROPBOX*	button. After clicking it follow the instructions to connect one of your Dropbox folders to *plgapp*. The folder's name should have the following name: `Apps/plgapp/{application-subdomain}`.

1. Inside your application's Dropbox folder you should create an `index.html` file which will be automatically served when you go to the application's URL at `https://{application-subdomain}-dev.app.plgrid.pl`. Try the following HTML snippet:

<!-- -->
	<!doctype html>
	<html>
		<head>
			<title>My first plgapp application</title>
			<script type="text/javascript" src="/plgapp/jquery/2.1.3/jquery.min.js"></script>
			<script type="text/javascript" src="/plgapp/plgapp.js"></script>
		</head>
		<body>
			<div>This is my first <em>plgapp</em> application.</div>
		</body>
	</html>
	
Development of auxiliary files such as JavaScript or CSS files is done the usual way. Put your files inside the application folder and include them in the HTML file with the proper tags (`<script>` or `<link>`). Libraries provided with the *plgapp* and their API is available on a [separate page](/help/js_libs).

#### Development files synchronization with a web form

If for some reason you cannot use Dropbox to synchronize your development files you can use a web form available in the application's panel *DEPLOY* tab to upload them as a zip archive. Remember that the root folder of the archive will be mapped to the root URL location of your application.

### Going to production

After the application is ready to be deployed to production (in this mode other users are able to access the application provided that the application is registered in the PL-Grid portal) just use the *PUSH TO PRODUCTION* button in the application's panel *DEPLOY* tab. 