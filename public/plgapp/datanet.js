var DataNetChainFactory = function(repositoryName, controller) {
	this.repositoryName = repositoryName;
	this.controller = controller;
	this.urlBase = '/datanet/{repoName}/';
	this.fieldValues = {};
	this.fieldNames = [];
	this.filters = [];
	
	//private methods
	
	this.processFetchResult = function(data, successCallback) {
		if(this.fieldNames.length > 0) {
			if(Array.isArray(data)) {
				var result = [];
				var object = {};
				//filtering fields
				for(var i = 0; i < data.length; i++) {
					object = {};
					
					for(var j = 0; j < this.fieldNames.length; j++) {
						object[this.fieldNames[j]] = data[i][this.fieldNames[j]];
					}
					
					result.push(object);
				}
				
				successCallback(result);
			} else {
				if(this.fieldNames.length == 1) {
					//returning single value
					successCallback(data[this.fieldNames[0]]);
				} else {
					//filtering object
					var object = {};
					
					for(var j = 0; j < this.fieldNames.length; j++) {
						object[this.fieldNames[j]] = data[this.fieldNames[j]];
					}
					
					successCallback(object);
				}
			}
		} else {
			successCallback(data);
		}
	};
	
	//public methods
	
	this.entity = function(entityName) {
		this.entityName = entityName;
		
		return this;
	};
	
	this.field = function(name, value) {
		if(value == null) {
			this.fieldNames.push(name);
		} else {
			this.fieldValues[name] = value;
		}
		
		return this;
	};
	
	this.fields = function(object) {
		if(Array.isArray(object)) {
			for(var i = 0; i < object.length; i++) {
				this.fieldNames.push(object[i]);
			}
		} else {
			for(var key in object) {
				if(object.hasOwnProperty(key)) {
					this.fieldValues[key] = object[key];
				}
			}
		}
		
		return this;
	};
	
	this.id = function(entityId) {
		this.entityId = entityId;
		
		return this;
	};
	
	this.create = function() {
		this.action = 'create';
		
		return this;
	};
	
	this.get = function() {
		this.action = 'get';
		
		return this;
	};
	
	this.update = function() {
		this.action = 'update';
		
		return this;
	};
	
	this.delete = function() {
		this.action = 'delete';
		
		return this;
	};
	
	this.search = function(filters) {
		this.action = 'search';
		this.filters = filters;
		
		return this;
	};
	
	this.then = function(successCallback, errorCallback) {
		switch(this.action) {
			case undefined:
			case null:
				errorCallback('None of the action methods were called (action methods: create(), get(), delete(), update(), search())');
				
				break;
			case 'create':
				if(this.repositoryName && this.entityName && Object.keys(this.fieldValues).length > 0) {
					var entityUrl = this.urlBase.replace('{repoName}', this.repositoryName) + this.entityName;
					this.controller.addEntityEntry(entityUrl, this.fieldValues, successCallback, errorCallback);
				} else {
					errorCallback('To create a new entity entry repository name, entity name and at least one field with value have to be given');
				}
				
				break;
			case 'get':
				var object = this;
				
				if(this.repositoryName && this.entityName && this.entityId) {
					var getUrl = this.urlBase.replace('{repoName}', this.repositoryName) + this.entityName + '/' + this.entityId;
					this.controller.get(getUrl, function(data) {
						object.processFetchResult(data, successCallback);
					}, errorCallback);
				} else if(this.repositoryName && this.entityName) {
					var getUrl = this.urlBase.replace('{repoName}', this.repositoryName) + this.entityName;
					this.controller.get(getUrl, function(data) {
						object.processFetchResult(data, successCallback);
					}, errorCallback);
				} else {
					errorCallback('Fetching requires providing at least repository and entity names');
				}
				
				break;
			case 'update':
				if(this.repositoryName && this.entityName && this.entityId && Object.keys(this.fieldValues).length > 0) {
					var updateUrl = this.urlBase.replace('{repoName}', this.repositoryName) + this.entityName + '/' + this.entityId;
					this.controller.update(updateUrl, this.fieldValues, successCallback, errorCallback);
				} else {
					errorCallback('Updating an entity entry requires providing repository name, entity name, entity id and at least one field with value');
				}
				
				break;
			case 'delete':
				if(this.repositoryName && this.entityName && this.entityId) {
					var deleteUrl = this.urlBase.replace('{repoName}', this.repositoryName) + this.entityName + '/' + this.entityId;
					this.controller.delete(deleteUrl, successCallback, errorCallback);
				} else {
					errorCallback('Deleting an entity entry requires providing repository name, entity name and entity id');
				}
				
				break;
			case 'search':
				var object = this;
				
				if(this.repositoryName && this.entityName && this.filters.length > 0) {
					var searchUrl = this.urlBase.replace('{repoName}', this.repositoryName) + this.entityName + '?';
					
					for(var i = 0; i < this.filters.length; i++) {
						searchUrl += this.filters[i];
						
						if(i < this.filters.length - 1) {
							searchUrl += '&';
						}
					}
					
					this.controller.get(searchUrl, function(data) {
						object.processFetchResult(data, successCallback);
					}, errorCallback);
				} else {
					errorCallback('Searching requires providing repository name, entity name and search filters');
				}
				
				break;
			default:
				errorCallback('Action ' + this.action + ' could not be recognized by the library');
		}
	};
};

var DataNet = function() {
	var factory = null;
	
	this.repository = function(name) {
		factory = new DataNetChainFactory(name, this);
		
		return factory;
	};
	
	this.addEntityEntry = function(entityUrl, values, successCallback, errorCallback) {
		plgapp.getInfo(function(error, userLogin, csrfToken) {
			if(error) {
				errorCallback(error.message);
			} else {
				$.ajax({
					url: entityUrl,
					method: 'POST',
					contentType: 'application/json',
					headers: {'X-CSRF-Token': csrfToken},
					data: values,
					success: function(data) {
						successCallback(data);
					},
					error: function(xhr, errorStatus, errorMessage) {
						errorCallback((errorStatus ? errorStatus + ': ' : '') + errorMessage);
					}
				});
			}
		});
	};
	
	this.get = function(url, successCallback, errorCallback) {
		$.ajax({
			url: url,
			method: 'GET',
			success: function(data) {
				successCallback(data);
			},
			error: function(xhr, errorStatus, errorMessage) {
				errorCallback((errorStatus ? errorStatus + ': ' : '') + errorMessage);
			}
		});
	};
	
	this.update = function(updateUrl, values, successCallback, errorCallback) {
		plgapp.getInfo(function(error, userLogin, csrfToken) {
			if(error) {
				errorCallback(error.message);
			} else {
				$.ajax({
					url: updateUrl,
					method: 'POST',
					contentType: 'application/json',
					headers: {'X-CSRF-Token': csrfToken},
					data: values,
					success: function(data) {
						successCallback(data);
					},
					error: function(xhr, errorStatus, errorMessage) {
						errorCallback((errorStatus ? errorStatus + ': ' : '') + errorMessage);
					}
				});
			}
		});
	};
	
	this.delete = function(deleteUrl, successCallback, errorCallback) {
		plgapp.getInfo(function(error, userLogin, csrfToken) {
			if(error) {
				errorCallback(error.message);
			} else {
				$.ajax({
					url: deleteUrl,
					method: 'DELETE',
					headers: {'X-CSRF-Token': csrfToken},
					success: function(data) {
						successCallback(data);
					},
					error: function(xhr, errorStatus, errorMessage) {
						errorCallback((errorStatus ? errorStatus + ': ' : '') + errorMessage);
					}
				});
			}
		});
	};
};

var datanet = new DataNet();