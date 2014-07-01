HH app

version: 0.0.1

//Elasticsearch structure

index - deals
	type - vegas
		fields -
		    deal_type
			duration : {
				start_dow
				end_dow
				start_tod
				end_tod	
			},
			offer : [{
				offer_type
				offer_val
				offer_desc
				item_type
				item_name
			}],
			provider : {
				id
				category
				title
			}

		}
			

	type - providers
		fields -
			category
			title
			address
			contact
			website
			details

//usecases:
1. Search by dow, tod, now
		filter by item category/name
		filter by place category/name
		filter by sale type
2. Free form Search - place name/category, item name/category

//bulk api
curl -s -XPOST localhost:9200/_bulk --data-binary @hh.json; echo

