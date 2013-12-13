timelinesApp.factory('ProjectType', ['$resource', 'APIDefaults', function($resource, APIDefaults) {

  ProjectType = $resource(
    APIDefaults.apiPrefix + '/project_types/:id.json',
    {}, {
      get: {
        // Explicit specification needed because of API reponse format
        method: 'GET',
        transformResponse: function(data) {
          return new ProjectType(angular.fromJson(data).project_type);
        }
      },
      query: {
        // Explicit specification needed because of API reponse format
        method: 'GET',
        isArray: true,
        transformResponse: function(data) {
          wrapped = angular.fromJson(data);
          return wrapped.project_types;
        }
      }
    });

  ProjectType.identifier = 'project_types';

  return ProjectType;
}]);
