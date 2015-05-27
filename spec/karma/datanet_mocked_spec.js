describe('DataNet test bundle', function() {
	describe('No network calls', function() {
		it('should check for datanet object', function() {
			expect(datanet).toBeDefined();
			expect(datanet).not.toBeNull();
		});
		
		it('should produce a chain factory', function() {
			var factory = datanet.repository('repository-name');
			expect(factory).not.toBeNull();
			expect(factory.controller instanceof DataNet).toBeTruthy();
			expect(factory.entity('entity-name')).not.toBeNull();
			expect(factory.entity('entity-name') instanceof DataNetChainFactory).toBeTruthy();
		});
		
		it('should persist repository and entity name', function() {
			var factory = datanet.repository('repository-name').entity('entity-name');
			expect(factory.repositoryName).toEqual('repository-name');
			expect(factory.entityName).toEqual('entity-name');
		});
		
		it('should call controller with add entry method', function() {
			spyOn(datanet, 'addEntityEntry');
			datanet.repository('repo').entity('entity').field('name', 'value').create().then(function() {}, function(error) {dump(error)});
			expect(datanet.addEntityEntry).toHaveBeenCalledWith('/datanet/repo/entity', jasmine.objectContaining({name: 'value'}),
					jasmine.anything(), jasmine.anything());
		});
		
		it('should allow to call field several times', function() {
			var factory = datanet.repository('repo').entity('entity').field('name1', 'value1').field('name2', 'value2');
			expect(factory.fieldValues).toEqual(jasmine.objectContaining({name1: 'value1', name2: 'value2'}));
		});
		
		it('should allow to call field and fields intechangeably', function() {
			var factory = datanet.repository('repo').entity('entity').field('name1', 'value1').fields({name2: 'value2', name3: 'value3'}).
					field('name3', 'value4');
			expect(factory.fieldValues).toEqual(jasmine.objectContaining({name1: 'value1', name2: 'value2', name3: 'value4'}));
		});
		
		it('should call on the error callback when no entity name is provided for the get action', function() {
			var errorCallback = jasmine.createSpy('errorCallback');
			datanet.repository('repo').get().then(function() {}, errorCallback);
			expect(errorCallback).toHaveBeenCalledWith(jasmine.stringMatching(/^Fetching requires /));
		});
	});
	
	describe('With mocked network calls', function() {
		beforeEach(function() {
			jasmine.Ajax.install();
		});
		
		afterEach(function() {
			jasmine.Ajax.uninstall();
		});
		
		it('should fetch single field value', function() {
			var success = jasmine.createSpy('success');
			var error = jasmine.createSpy('error');
			datanet.repository('repo').entity('entity').id('id').field('field').get().then(success, error);
			
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity/id');
			request.respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '{"field": "value1", "field2": "value2"}'
			});
			
			expect(success).toHaveBeenCalledWith('value1');
			expect(error).not.toHaveBeenCalled();
		});
		
		it('should return a single entity object', function() {
			var success = jasmine.createSpy('success');
			datanet.repository('repo').entity('entity').id('id').get().then(success, function(error) {});
			
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity/id');
			request.respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '{"field": "value1", "field2": "value2"}'
			});
			
			expect(success).toHaveBeenCalledWith(jasmine.objectContaining({field: 'value1', field2: 'value2'}));
		});
		
		it('should return a single entity object with filtered fields', function() {
			var success = jasmine.createSpy('success');
			datanet.repository('repo').entity('entity').id('id').fields(['field', 'field2']).get().then(success, function(error) {});
			
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity/id');
			request.respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '{"field": "value1", "field2": "value2", "field3": "value3"}'
			});
			
			expect(success).toHaveBeenCalledWith({field: 'value1', field2: 'value2'});
		});
		
		it('should return a list of entity entries', function() {
			var success = jasmine.createSpy('success');
			datanet.repository('repo').entity('entity').get().then(success, function(error) {});
			
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity');
			request.respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '[{"field": "value1", "field2": "value2"}, {"field": "value3", "field2": "value4"}]'
			});
			
			expect(success).toHaveBeenCalledWith([{field: 'value1', field2: 'value2'}, {field: 'value3', field2: 'value4'}]);
		});
		
		it('should return a list of entity entries with filtered fields', function() {
			var success = jasmine.createSpy('success');
			datanet.repository('repo').entity('entity').field('field').get().then(success, function(error) {});
			
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity');
			request.respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '[{"field": "value1", "field2": "value2"}, {"field": "value3", "field2": "value4"}]'
			});
			
			expect(success).toHaveBeenCalledWith([{field: 'value1'}, {field: 'value3'}]);
		});
		
		it('should create a new entity entry', function() {
			var success = jasmine.createSpy('success');
			var error = jasmine.createSpy('error');
			datanet.repository('repo').entity('entity').field('field', 'value').create().then(success, error);
			jasmine.Ajax.requests.mostRecent().respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '{"csrfToken": "token", "userLogin": "login", "development": false}'
			});
			jasmine.Ajax.requests.mostRecent().respondWith({
				status: 201,
				contentType: 'application/json',
				responseText: '{"id": "idValue"}'
			});
			
			expect(error).not.toHaveBeenCalled();
			expect(success).toHaveBeenCalledWith({id: 'idValue'});
		});
		
		it('should update an existing entity entry', function() {
			var success = jasmine.createSpy('success');
			var error = jasmine.createSpy('error');
			datanet.repository('repo').entity('entity').id('id').field('field', 'value').update().then(success, error);
			jasmine.Ajax.requests.mostRecent().respondWith({
				status: 201,
				contentType: 'application/json',
				responseText: '{}'
			});
			
			expect(error).not.toHaveBeenCalled();
			expect(success).toHaveBeenCalledWith({});
		});
		
		it('should delete an existing entity entry', function() {
			var success = jasmine.createSpy('success');
			var error = jasmine.createSpy('error');
			datanet.repository('repo').entity('entity').id('id').delete().then(success, error);
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity/id');
			expect(request.method).toBe('DELETE');
			request.respondWith({
				status: 201,
				contentType: 'application/json',
				responseText: '{}'
			});
			
			expect(error).not.toHaveBeenCalled();
			expect(success).toHaveBeenCalledWith({});
		});
		
		it('should search for entries', function() {
			var success = jasmine.createSpy('success');
			var error = jasmine.createSpy('error');
			datanet.repository('repo').entity('entity').search(['name=/John.*/', 'surname=Smith']).then(success, error);
			var request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toBe('/datanet/repo/entity?name=/John.*/&surname=Smith');
			expect(request.method).toBe('GET');
			request.respondWith({
				status: 200,
				contentType: 'application/json',
				responseText: '[{"name": "John", "surname": "Smith"}]'
			});
			
			expect(error).not.toHaveBeenCalled();
			expect(success).toHaveBeenCalledWith([{name: 'John', surname: 'Smith'}]);
		});
	});
});