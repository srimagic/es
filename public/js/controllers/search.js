function search($scope, $http) {
	$scope.query = function() {
		var request = $http({method:'get',                                                                                                        
                    url:'/search',                                                                                                               
                    params: {
                    	'dow': $scope.dow,
                    	'tod': $scope.tod,
                    	'query_string': $scope.query_string
                    }                                                                                                              
        });                                                                                                                                
                                                                                                                                                       
	    request.success(function(result){                                                                                                        
	    	$scope.result = result;                                              
	    });                                                                                                                                       
	                                                                                                                                             
	    request.error(function(err){  
	    	$scope.result = err;                                         
	    });
	};
	$scope.$watch('dow + tod', $scope.query, true);
}