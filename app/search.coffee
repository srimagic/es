

exports.addRoutes = (app) ->
  app.get "/search", (req, res) ->
    dayofweek = 0
    timeofday = 0
    must = []
    filters = []
    query_string = 
      match_all:
        {}

    if req.query
      dayofweek = req.query.dow || 0
      if dayofweek
        must.push 
          range:
            start_dow:
              lte:
                dayofweek
        must.push 
          range:
            end_dow:
              gte:
                dayofweek

      timeofday = req.query.tod || 0
      if timeofday
        must.push 
          range:
            start_tod:
              lte:
                timeofday
        must.push 
          range:
            end_tod:
              gte:
                timeofday

    filters.push(
      nested:
        path:
          "duration"
        filter:
          bool:
            must: 
              must
    )

    additional_filter = 0
    placetype = req.query.placetype || 0
    if placetype
      additional_filter = placetype

    itemtype = req.query.itemtype || 0
    if itemtype
      additional_filter = additional_filter + ' AND ' + itemtype

    if additional_filter
      filters.push(
        query:
          query_string:
            query: 
              additional_filter
      )      
    
    query =
      filtered:
        strategy:
          "leap_frog_filter_first"
        query:
          query_string
        filter:
          and: 
            filters
          
    input =
      index:
        "deals"
      type:
        "vegas"
      body:
        query:
          query

    console.log 'input=', JSON.stringify input

    app.es.search input, (err, result) ->
      if err
        console.log 'err=', JSON.stringify err
        res.send 400, err
      else
        res.send 200, result
