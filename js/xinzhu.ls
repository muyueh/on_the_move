# TODO remove map style
# use canvas instead of SVG

colorDead = "\#de2d26"
colorAcci = "rgb(255, 204, 0)"


## used by map and crossfilter
lngDim = null
latDim = null
projection = null

overlay = null
padding = 5
mapOffset  = 4000
weekDayTable = ["Sun.", "Mon.", "Tue.", "Wed.", "Thu.", "Fri.", "Sat."]
gPrints = null

monthDim = null
weekdayDim = null
hourDim = null
map = null

barAcciHour = null

styledMap = new google.maps.StyledMapType(
	[
		{
				"featureType": "water",
				"elementType": "geometry",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 17
						}
				]
		},
		{
				"featureType": "landscape",
				"elementType": "geometry",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 20
						}
				]
		},
		{
				"featureType": "road.highway",
				"elementType": "geometry.fill",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 17
						}
				]
		},
		{
				"featureType": "road.highway",
				"elementType": "geometry.stroke",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"weight": 0.2
						},
						{
								"lightness": 29
						}
				]
		},
		{
				"featureType": "road.arterial",
				"elementType": "geometry",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 18
						}
				]
		},
		{
				"featureType": "road.local",
				"elementType": "geometry",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 16
						}
				]
		},
		{
				"featureType": "poi",
				"elementType": "geometry",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 21
						}
				]
		},
		{
				"featureType": "all",
				"elementType": "labels.text.stroke",
				"stylers": [
						{
								"visibility": "on"
						},
						{
								"color": '#000000'
						},
						{
								"lightness": 16
						}
				]
		},
		{
				"featureType": "all",
				"elementType": "labels.text.fill",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 40
						}
				]
		},
		{
				"featureType": "all",
				"elementType": "labels.icon",
				"stylers": [
						{
								"visibility": "off"
						}
				]
		},
		{
				"featureType": "transit",
				"elementType": "geometry",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 19
						}
				]
		},
		{
				"featureType": "administrative",
				"elementType": "geometry.fill",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"lightness": 20
						}
				]
		},
		{
				"featureType": "administrative",
				"elementType": "geometry.stroke",
				"stylers": [
						{
								"color": '#000000'
						},
						{
								"weight": 1.2
						},
						{
								"lightness": 17
						}
				]
		}
	],
	{name: "Styled Map"})



initMap = -> 
	map := new google.maps.Map(d3.select "\#map" .node!, {
		zoom: 12,
		center: new google.maps.LatLng(24.80363496720421, 120.96827655517575),
		mapTypeControlOptions:{
			mapTypeId: [google.maps.MapTypeId.ROADMAP, 'map_style']
		}
	})

	google.maps.event.addListener(map, "bounds_changed", -> 
		bounds = @getBounds!
		northEast = bounds.getNorthEast!
		southWest = bounds.getSouthWest!

		console.log [(southWest.lng! + northEast.lng!) / 2, (southWest.lat! + northEast.lat!) / 2]


		lngDim.filterRange([southWest.lng!, northEast.lng!])
		latDim.filterRange([southWest.lat!, northEast.lat!])

		dc.redrawAll!
	)

	map.mapTypes.set('map_style', styledMap)
	map.setMapTypeId('map_style')

	overlay.setMap(map)


transform = (d)->

	d = new google.maps.LatLng(d.GoogleLat, d.GoogleLng)
	d = projection.fromLatLngToDivPixel(d)

	return d3.select(this)
		.style("left", (d.x - padding) + "px")
		.style("top", (d.y - padding) + "px")

ifdead = (it, iftrue, iffalse)-> if (it.dead > 0) then iftrue else iffalse

setCircle = ->
	it.attr {
		"cx": -> it.coorx
		"cy": -> it.coory
		"r": -> ifdead it, "5px", "2.5px"
	}
	.style {
		"fill": -> ifdead it, colorDead, colorAcci
		"position": "absolute"
		"opacity": -> ifdead it, 1, 0.3
	}

initCircle = ->
	it.style {
		"opacity": 0
	}

tranCircle = ->
	it.style {
		"opacity": -> ifdead it, 1, 0.3
	}

updateGraph = ->

	dt = gPrints.selectAll "circle"
		.data monthDim.top(Infinity)

	dt
		.enter!
		.append "circle"
		.call setCircle
		# .call initCircle
		# .transition!
		# .call tranCircle

	dt
		.call setCircle
		# .call initCircle
		# .transition!
		# .call tranCircle

	dt
		.exit!
		# .transition!
		# .call initCircle
		.remove!



err, tsvBody <- d3.tsv "./accidentXY_light.tsv"

deadData = []
tsvBody.filter( (d)->

	d.GoogleLng = +d.GoogleLng
	d.GoogleLat = +d.GoogleLat

	d.date = new Date(d["å¹´"], d["æœˆ"], d["æ—¥"], d["æ™‚"], d["åˆ†"])
	d.week = weekDayTable[d.date.getDay!]
	d.dead = (+d["2-30"]) + (+d["æ­»"])

	if d.dead > 0
		deadData.push(d)
	return true
)

#map
overlay := new google.maps.OverlayView!

overlay.onAdd = ->

	layer = d3.select(@getPanes().overlayLayer).append("div")
		.attr("class", "stationOverlay")

	svg = layer.append "svg"

	gPrints := svg.append "g"
		.attr {
			"class" "gPrints"
		}

	svg
		.attr {
			"width": mapOffset * 2
			"height": mapOffset * 2
		}
		.style {
			"position": "absolute"
			"top": -1 * mapOffset + "px"
			"left": -1 * mapOffset + "px"
		}


	overlay.draw = ->

		projection := @getProjection()
		
		googleMapProjection = (coordinates)->

			googleCoordinates = new google.maps.LatLng(coordinates[0], coordinates[1])
			pixelCoordinates = projection.fromLatLngToDivPixel googleCoordinates
			[pixelCoordinates.x + mapOffset, pixelCoordinates.y + mapOffset]


		tsvBody.filter ->
			coor = googleMapProjection [it.GoogleLat, it.GoogleLng]
			it.coorx = coor[0]
			it.coory = coor[1]
			true


		dt = gPrints.selectAll "circle"
			.data tsvBody

		dt
			.enter!
			.append "circle"
			.call setCircle

		dt
			.call setCircle

		dt
			.exit!
			.remove!


#dc.js
barPerMonth = dc.barChart("\#DeathMonth")
barPerWeekDay = dc.barChart("\#DeathWeekDay")
barPerHour = dc.barChart("\#DeathHour")

barAcciMonth = dc.barChart("\#AcciMonth")
barAcciWeekDay = dc.barChart("\#AcciWeekDay")
barAcciHour := dc.barChart("\#AcciHour")


ndx = crossfilter(tsvBody)
all = ndx.groupAll!

monthDim := ndx.dimension( ->	it["æœˆ"])
weekdayDim := ndx.dimension( -> it.week )
hourDim := ndx.dimension( -> it.["æ™‚"] )

lngDim := ndx.dimension( -> it.GoogleLng )
latDim := ndx.dimension( -> it.GoogleLat )

acciMonth = monthDim.group!.reduceCount!
acciWeekDay = weekdayDim.group!.reduceCount!
acciHour = hourDim.group!.reduceCount!

deathMonth = monthDim.group!.reduceSum(-> it.dead)
deathWeekDay = weekdayDim.group!.reduceSum(-> it.dead)
deathHour = hourDim.group!.reduceSum(-> it.dead)

barMt = 350
barWk = 270
barHr = 550

marginMt = {
	"top": 10,
	"right": 10,
	"left": 30,
	"bottom": 20
}

marginWk = marginMt
marginHr = marginMt

barPerMonth.width(barMt)
	.height(100)
	.margins marginMt
	.dimension(monthDim)
	.group(deathMonth)
	.x(d3.scale.ordinal!.domain(d3.range(1,13)))
	.xUnits(dc.units.ordinal)
	.elasticY(true)
	.colors(colorDead)
	.on("filtered", (c, f)-> updateGraph!)
	.yAxis!
	.ticks(3)


barPerWeekDay.width(barWk)
	.height(100)
	.margins(marginWk)
	.dimension(weekdayDim)
	.group(deathWeekDay)
	.x(d3.scale.ordinal!.domain(weekDayTable))
	.xUnits(dc.units.ordinal)
	.gap(4)
	.elasticY(true)
	.colors(colorDead)
	.on("filtered", (c, f)-> updateGraph!)
	.yAxis!
	.ticks(3)

barPerHour.width(barHr)
	.height(100)
	.margins(marginHr)
	.dimension(hourDim)
	.group(deathHour)
	.x(d3.scale.linear!.domain([0, 24]))
	.elasticY(true)
	.colors(colorDead)
	.on("filtered", (c, f)-> updateGraph!)
	.yAxis!
	.ticks(3)


#accident

barAcciMonth.width(barMt)
	.height(100)
	.margins(marginMt)
	.dimension(monthDim)
	.group(acciMonth)
	.x(d3.scale.ordinal!.domain(d3.range(1,13)))
	.xUnits(dc.units.ordinal)
	.elasticY(true)
	.colors(colorAcci)
	.on("filtered", (c, f)-> updateGraph!)
	.yAxis!
	.ticks(4)


barAcciWeekDay.width(barWk)
	.height(100)
	.margins(marginWk)
	.dimension(weekdayDim)		
	.group(acciWeekDay)
	.x(d3.scale.ordinal!.domain(weekDayTable))
	.xUnits(dc.units.ordinal)
	.elasticY(true)
	.gap(4)
	.colors(colorAcci)
	.on("filtered", (c, f)-> updateGraph!)
	.yAxis!
	.ticks(4)

barAcciHour.width(barHr)
	.height(100)
	.margins(marginHr)
	.dimension(hourDim)
	.group(acciHour)
	.x(d3.scale.linear!.domain([0, 24]))
	.elasticY(true)
	.colors(colorAcci)
	.on("filtered", (c, f)-> updateGraph!)
	.yAxis!
	.ticks(4)



dc.renderAll!

initMap!



### for navigation
navls = [
	{"ttl":"Accident Crossfilter", "txt": "Accidents from the Xinzhu area in Taiwan are visualized in the period January to October 2013 â€“ a total of 13,200 accidents and 25+ deaths. Orange represents accidents, and red are accidents where death occurred. </br></br>(Click here to start navigation.)", "act": (
		-> 

		)}
	{"ttl":"Death by Month â€“ 2013", "txt": "Here are the statistics by months: Orange represents accidents, and red accidents involved a death. Notice that there were no deaths in April, although the accident count is relatively high. (Click here for Day of the Week)", "act": (
		->
			d3.selectAll ".fltWeek, .fltHour"
				.transition!
				.style {
					"opacity": 0.2
				}

		)}
	{"ttl":"Day of the Week", "txt": "Accidents on days of the week are relatively even; however, in our dataset, there were no accidents death on Monday. (Click here for Hour of the Day)", "act": (
		->
			d3.selectAll ".fltMonth, .fltHour"
				.transition!
				.style {
					"opacity": 0.2
				}
			d3.selectAll ".fltWeek"
				.transition!
				.style {
					"opacity": 1
				}

		)}
 
	{"ttl":"Hour of the Day", "txt": "Accidents decreased after 7 pm, and the lowest number occurred between 0 am to 7 am. When we look at accident deaths, however, 0 am to 7 am is very deadly. To prevent accident deaths, this time period is a good place to start.</br></br>This is interesting, but where exactly are these accidents? (Click here to find out)", "act": (
		->
			d3.selectAll ".fltMonth, .fltWeek"
				.transition!
				.style {
					"opacity": 0.2
				}
			d3.selectAll ".fltHour"
				.transition!
				.style {
					"opacity": 1
				}

		)}
	{"ttl":"Analysis with a Click", "txt": "If you drag your mouse from 0 am to 7 am, all the accidents are highlighted on the map (1 sec response time). Notice that the week and month charts are updated according to your action. (Click here for Crossfilter)", "act": (
		->
			d3.selectAll ".filter"
				.transition!
				.style {
					"opacity": 1
				}

			hourDim.filter [0, 8]

		)}
	{"ttl":"Crossfilter", "txt": "You can also select multiple criteria, such as the accidents that happened from 0 am to 7 am on weekends. For these criteria, drag your mouse for the timeframe and then click on Saturday and Sunday. (Click here for Geo-Crossfilter)", "act": (
		->
			weekdayDim.filter ["Sat", "Sun"]

		)}
	{"ttl":"Geo-Crossfilter", "txt": "This also work the other way, we can zoom-in into any part of the map, and the charts will update accordingly. Now we are viewing the area around the train station. (Click here for another Geo-Crossfilter)", "act": (
		->
			map.setZoom 13
			setTimeout(
				-> 
					map.setZoom 14
					setTimeout(
					-> 
						map.setZoom 15
						setTimeout(
						-> 
							map.setZoom 16
						, 100)
					, 100)
				, 100)
		)}

	{"ttl":"Geo-Crossfilter", "txt": "Now weâ€™re around Chiao Tung University.</br></br>The benefit of programming-generated visualization is that once developed, we just feed in different data to generate an up-to-date graph.</br></br>Start exploring on your own! Zoom in and out use the sliding scale on the left. You can use the directional arrows to move around the map or just drag the map itself from one part of the city to another.", "act": (
		->
			map.panTo {lat: 24.799232620011438, lng:120.98143010818478}

		)}
]


navidx = 0
do nav = ->
	ctn = navls[navidx]
	l = navls.length - 1

	if navidx > l
		d3.selectAll ".ctn-nav"
			.transition!
			.style {
				"opacity": 0
			}
	else
		d3.selectAll ".navttl"
		.text ctn.ttl

		d3.selectAll ".navidx"
			.text navidx + "/" + l

		d3.selectAll ".navtxt"
			.html ctn.txt

		ctn.act!		

d3.selectAll ".ctn-nav"
	.on "mousedown", -> 
		++navidx
		nav!

