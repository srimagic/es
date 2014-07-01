

exports.addRoutes = (app) ->
  app.get "/search", (req, res) ->
    dayofweek = 0
    timeofday = 0
    must = []
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

      if req.query.query_string
        query_string =  
          multi_match:
            query: req.query.query_string
            fields: ["provider.title", "provider.category", "offer.offer_desc", "offer.item_name", "offer.item_type"]         
    
    query =
      filtered:
        strategy:
          "leap_frog_filter_first"
        query:
          query_string
        filter:
          nested:
            path:
              "duration"
            filter:
              bool:
                must: 
                  must
    
    
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
