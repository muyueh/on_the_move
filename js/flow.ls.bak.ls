{Str, fold1, obj-to-lists, lists-to-obj, flatten, unique, map, curry} = require "prelude-ls"

## actually don't know the value for male

ggl = {}
# ggl.headName = "地区"

ggl.margin = {top: 20, left: 50, right: 100, bottom: 50}
ggl.w = 400 - ggl.margin.left - ggl.margin.right
ggl.h = 800 - ggl.margin.top - ggl.margin.bottom

ggl.snky = {right: 100, bottom: 50}
ggl.paths = null

ggl.clrOrange = "rgb(253, 141, 60)"
ggl.clrRed = "rgb(215, 48, 39)"
ggl.clrBlue = "rgb(69, 117, 180)"

ggl.nmtbl = {
	"110":	"北京市"
	"120":	"天津市"
	"130":	"河北省"
	"140":	"山西省"
	"150":	"内蒙古"
	"210":	"辽宁省"
	"220":	"吉林省"
	"230":	"黑龙江"
	"310":	"上海市"
	"320":	"江苏省"
	"330":	"浙江省"
	"340":	"安徽省"
	"350":	"福建省"
	"360":	"江西省"
	"370":	"山东省"
	"410":	"河南省"
	"420":	"湖北省"
	"430":	"湖南省"
	"440":	"广东省"
	"450":	"广西省"
	"460":	"海南省"
	"500":	"重庆市"
	"510":	"四川省"
	"520":	"贵州省"
	"530":	"云南省"
	"540":	"西藏"
	"610":	"陕西省"
	"620":	"甘肃省"
	"630":	"青海省"
	"640":	"宁夏"
	"650":	"新疆兵团"
}

ggl.p23tbl = {
	"01":	"预防保健科"
	"02":	"全科医疗科"
	"03":	"内科"
	"04":	"外科"
	"05":	"妇产科"
	"06":	"妇女保健科"
	"07":	"儿科"
	"08":	"小儿外科"
	"09":	"儿童保健科"
	"10":	"眼科"
	"11":	"耳鼻咽喉科"
	"12":	"口腔科"
	"13":	"皮肤科"
	"14":	"医疗美容科"
	"15":	"精神科"
	"16":	"传染科"
	"17":	"结核病科"
	"18":	"地方病科"
	"19":	"肿瘤科"
	"20":	"急诊医学科"
	"21":	"康复医学科"
	"22":	"运动医学科"
	"23":	"职业病科"
	"24":	"临终关怀科"
	"25":	"特种医学与军事医学科"
	"26":	"麻醉科"
	"27":	"疼痛科"
	"28":	"重症医学科"
	"30":	"医学检验科"
	"31":	"病理科"
	"32":	"医学影像科"
	"50":	"中医科"
	"51":	"民族医学科"
	"52":	"中西医结合科"
	"69":	"其他业务科室"
}

ggl.age_grptbl = {
	"0": "17 及以下"
	"1": "18 到 44"
	"2": "45 到 64"
	"3": "65 及以上"
}

ggl.age_sextbl = {
	"1": "男"
	"2": "女"
}

getY = (str)-> +(Str.take 4, str)
getM = (str)-> +(Str.drop 4, str)

dragMove = ->
	
	d3.select @
		.attr {
			"transform": "translate(" + it.x + "," + (it.y = Math.max 0, Math.min(ggl.h - it.dy, d3.event.y)) + ")"
		}
	ggl.sankey.relayout!
	ggl.paths.attr { "d": ggl.path 1 }



tsv2Json = (tsvData)-> 
# ## input: [{地區: "北京", 南京: "10"}]
# ## output: {source: , target: , value: }

	jsonData = []
	tsvData.filter (row, i)->
		if row.from_proid is "000" or row.from_proid is "650" or row.po_id is "650" or (row.sex is "-1") or ((getY row.cycle) is 2010) or ((getY row.cycle) is 2012) then return false
		row.sum_spend1000 = +row.sum_spend1000
		row.count = +row.count
		row.source= row.from_proid
		row.target = row.po_id
		row.value = row.count

		row.p23_new = ggl.p23tbl[row.p23_new]
		row.age_grp = ggl.age_grptbl[row.age_grp]
		row.sex = ggl.age_sextbl[row.sex]		
		# row.month = getM row.cycle
		# row.year = getY row.cycle

		jsonData.push row


	jsonData


sumupST = (jsonData)->
	tbl = {}
	jsonData.map (row, i)->
		str = row.source + "_" + row.target
		if tbl[str] is undefined
			tbl[str] := {}
			tbl[str].source = row.source
			tbl[str].target = row.target
			tbl[str].value = 0
		tbl[str].value += row.value

	(obj-to-lists tbl)[1]

sumupV = curry (against, jsonData)->
	tbl = {}
	jsonData.map (row, i)->
		str = row[against]
		if tbl[str] is undefined
			tbl[str] := {}
			tbl[str].name = row[against]
			tbl[str].value = 0
		++tbl[str].value


	(obj-to-lists tbl)[1]

sumSex = sumupV "sex"
sumAge = sumupV "age_grp"
sumYM = sumupV "cycle"
sumDs = sumupV "p23_new"

json2NodeLink = (jsonData)->
##input: {source: , target: , value: }
##output: {nodes: [input],links: input}
	rslt = {}
	## use "s-", "t-" because dest and orgin share same name but we want to be different nodes
	lsnames = (jsonData.map -> ["s-" + it.source, "t-" + it.target]) |> flatten |> unique
	rslt.nodes = lsnames |> map (-> {name: (it.split "-")[1]})


	##use index
	tbl = lists-to-obj lsnames, [0 to lsnames.length - 1]

	rslt.links = jsonData.map (row)->
		{
			"source": tbl["s-" + row.source]
			"target": tbl["t-" + row.target]
			"value": row.value
		}

	rslt


ggl.sankey = d3.sankey!
	.size [ggl.w - ggl.snky.right, ggl.h - ggl.snky.bottom]
	.nodeWidth 15
	.nodePadding 10

ggl.path = ggl.sankey.reversibleLink!

buildSankey = (data)->
## data.nodes, data.links
## magical number!!
	# console.log data

	ggl.sankey
		.nodes data.nodes
		.links data.links
		.layout 1

	svg = d3.select "body"
		.select ".mainchart"
		.append "svg"
		.attr {
			"width": ggl.w
			"height": ggl.h
		}
		.append "g"
		.attr {
			"transform": "translate(" + ggl.margin.left + "," + ggl.margin.top + ")"
		}

	

	linkEnter = svg.append "g"
		.selectAll ".linkGrp"
		.data data.links
		.enter!
		.append "g"
		.attr {
			"class": ->
				# console.log it
				"linkGrp"
		}
		.sort (a, b)-> b.dy - a.dy

	highStyle = ->
		it.style {
			"opacity": 0.8
		}

	normStyle = ->
		it.style {
			"opacity": 0.4
		}

	hideStyle = ->
		it.style {
			"opacity": 0.1
		}


	ggl.paths := linkEnter.append "path"
		.attr {
			"fill": ggl.clrOrange			
			"d": ggl.path 1
			"class": -> "t" + it.target.name + " s" + it.source.name + " linkPath"
		}
		.call normStyle
		.on "mouseover", -> 
			d3.select @ 
				.call highStyle

			d3.selectAll ".ps" + it.source.name
				.text ~~(it.value / it.source.value * 100 ) + "%"

			d3.selectAll ".pt" + it.target.name
				.text ~~(it.value / it.target.value * 100 ) + "%"

		.on "mouseout", -> 
			d3.select @ 
				.call normStyle

			d3.selectAll ".ps" + it.source.name
				.text ""

			d3.selectAll ".pt" + it.target.name
				.text ""


	node = svg.append "g"
		.selectAll ".node"
		.data data.nodes
		.enter!
		.append "g"
		.attr {
			"class": "node"
			"transform": -> "translate(" + it.x + "," + it.y + ")"
		}
		.call(
			d3.behavior.drag!
				.origin -> it
				.on "dragstart", -> @.parentNode.appendChild @
				.on "drag", dragMove
			)
		
	
	tOrS = ->
		return if it.sourceLinks.length > it.targetLinks.length then "s" else "t"

	tOrSJson = -> 
		if it.sourceLinks.length < it.targetLinks.length
			return {
				i: "t"
				j: "s"
				k: "target"
				l: "source"
			}
		else
			return {
				i: "s"
				j: "t"
				k: "source"
				l: "target"
			}

	node.append "rect"
		.attr {
			"height": -> it.dy
			"width": ggl.sankey.nodeWidth!
			"fill": ggl.clrOrange
		}
		.on "mouseover", ->
			d3.selectAll ".linkPath:not(" + (tOrS it)  + it.name + ")"
				.call hideStyle
			d3.selectAll "." + (tOrS it)  + it.name
				.call highStyle

			r = tOrSJson it
			it[r.k + "Links"]map (lk)->
				d3.selectAll ".p" + r.j + lk[r.l]name
					.text -> 
						s = ~~(lk.value / lk[r.l]value * 100 )
						return if s is 0 then "" else s + "%"
		.on "mouseout", ->
			d3.selectAll ".linkPath"
				.call normStyle

			r = tOrSJson it

			it[r.k + "Links"]map (lk)->
				d3.selectAll ".p" + r.j + lk[r.l]name
					.text ""


	node.append "text"
		.attr {
			"x": -6
			"y": -> it.dy / 2
			"dy": "0.35em"
			"text-anchor": "end"
			"transform": null
		}
		.text -> ggl.nmtbl[it.name]

	node.append "text"
		.attr {
			"x": 45
			"y": -> it.dy / 2
			"dy": "0.35em"
			"text-anchor": "end"
			"transform": null
			"class": -> "p" + (tOrS it)  + it.name
		}
		# .text -> it.name


buildMargin = ->
	rslt = {}
	rslt.margin = {top: 30, left: 30, bottom: 30, right: 30}
	rslt.w = 400 - rslt.margin.left - rslt.margin.right
	rslt.h = 200 - rslt.margin.top - rslt.margin.bottom

	rslt


buildSvg = (margin)->
	d3.select "body"
		.select ".sidechart"
		.append "svg"
		.attr {
			"width": margin.w
			"height": margin.h
		}
		.append "g"
		.attr {
			"transform": "translate(" + margin.margin.left + "," + margin.margin.top + ")"
		}

builGenderBar = (data)->

	## init
	bar = buildMargin!
	svg = buildSvg bar
	## init end

	ttl = (data.map -> it.value) |> fold1 (+), _
	# console.log ttl

	sclBar = d3.scale.linear!
		.domain [0, ttl]
		.range [0, bar.w]

	offset = 0
	data = data.filter (it, i)->
		it.x0 = offset
		offset += sclBar it.value

	clr = d3.scale.category10!

	rct = svg
		.selectAll ".rect"
		.data data
		.each -> 
		.enter!
		.append "rect"
		.attr {
			"width": -> sclBar it.value
			"height": 15
			"x":(it, i)-> it.x0
		}
		.style {
			
			"fill": (it, i)-> clr i
			# if it.name is "1" then ggl.clrBlue else ggl.clrRed
		}
		.append "title"
		.text (it, i)-> it.name

renderAll = ->
	lsFunc.map -> it.render!


# ## add national wise benchmark
# buildHorizonBar = (group)->
# 	## init
# 	bar = buildMargin!
# 	svg = buildSvg bar
# 	## init end

# 	ttl = (group.map -> it.value) |> fold1 (+), _

# 	sclBar = d3.scale.linear!
# 		.domain [0, ttl]
# 		.range [0, bar.w]

# 	dt = svg.selectAll ".rect"
# 		.data group.sort (a, b)-> b.value - a.value
# 		.enter!

# 	rct = dt.append "rect"
# 		.attr {
# 			"width": -> sclBar it.value
# 			"height": 15
# 			"x":(it, i)-> it.x0
# 			"y":(it, i)-> i * 17
# 		}
# 		.style {
# 			"fill": (it, i)-> ggl.clrOrange
# 		}
# 		.append "title"
# 		.text (it, i)-> it.key

# 	dt.append "text"
# 		.attr {
# 			"x":(it, i)-> it.x0
# 			"y":(it, i)-> i * 17 + 13
# 		}
# 		.text (it, i)-> it.key


getSetter = (build, loc)->
	for let it of loc
		build[it] = (v)->
			if arguments.length is 0
				return loc[it]
			else 
				loc[it] := v
				build


reBuildSvg = ->
	loc = buildMargin!
	loc.selector = ".sidechart"

	build = ->
		d3.select "body"
			.select loc.selector
			.append "svg"
			.attr {
				"width": loc.w
				"height": loc.h
			}
			.append "g"
			.attr {
				"transform": "translate(" + loc.margin.left + "," + loc.margin.top + ")"
			}


	getSetter build, loc	
	build



reBuildHorizonBar = ->
	loc = buildMargin!
	loc.group = null
	loc.dimension = null
	loc.rectHeight = 15
	loc.rectMargin = 2
	# console.log loc

	dt = null
	sclBar = null
	ttl = null
	rct = null

	rctAttr = ->
		it.attr {
			"width": -> sclBar it.value
			"height": loc.rectHeight
			"x":(it, i)-> 0
			"y":(it, i)-> i * (loc.rectHeight + loc.rectMargin)
		}
		.style {
			"fill": (it, i)-> ggl.clrOrange
		}
	txtAttr = ->
		it.attr {
			"x":(it, i)-> 100
			"y":(it, i)-> i * (loc.rectHeight + loc.rectMargin) + 13
		}
		.text (it, i)-> it.key


	build = ->
		## will this build too much duplicated chart?

		##auto adjust chart length
		# loc.height := loc.group.length * (loc.rectHeight + loc.rectMargin) + loc.margin.top + loc.margin.bottom

		loc.svg := reBuildSvg!.h(loc.group.length * (loc.rectHeight + loc.rectMargin) + loc.margin.top + loc.margin.bottom)

		ttl := (loc.group.map -> it.value) |> fold1 (+), _
		sclBar := d3.scale.linear!
			.domain [0, ttl]
			.range [0, loc.w]

		dt := loc.svg!
			.selectAll ".rect"
			.data loc.group
			.enter!
			.append "g"
			.attr {
				"class": "horBar"
			}

		rct := dt.append "rect"
			.call rctAttr
			.on "mousedown", ->
				k = d3.select(@).data![0].key
				loc.dimension.filter k
				renderAll!

		dt.append "text"
			.call txtAttr
			

	build.render = ->
		console.log loc.group

		rct
			.transition!
			.call rctAttr

		# dt.append "text"
		# 	.transition!
		# 	.call txtAttr

	getSetter build, loc
	build



buildHeatMap = (data)->
	heat = buildMargin!
	heat.height = 400
	heat.rect = {}
	heat.rect.width = 10
	heat.rect.height = 10
	heat.rect.margin = 5
	heat.rect.unit = (heat.rect.width + heat.rect.margin)

# tmpYM = ([2013 to 2014].map (y)-> [1 to 12].map (m)-> {"year": y, "month": m}) |> flatten

	svg = buildSvg heat

	sclHeat = d3.scale.linear!
		.domain d3.extent(data, -> it.value)
		.range [0, 1]

	svg.selectAll "rect"
		.data data
		.enter!
		.append "rect"
		.attr {
			"width": heat.rect.width
			"height": heat.rect.height
			"x": (it, i)-> (((getM it.name)- 1) % 12) * heat.rect.unit
			"y": (it, i)-> ~~((getY it.name) - 2009) * heat.rect.unit
		}
		.style {
			"opacity": (it, i)-> sclHeat it.value
			"fill": (it, i)-> ggl.clrOrange
		}


lsExc = null
lsFunc = null

err, tsvBody <- d3.tsv "../transform/group/transfer_t10.tsv"

json = tsvBody |> tsv2Json 

# json |> sumupST |> console.log

json |> sumupST |> json2NodeLink |> buildSankey

# json |> sumSex |> builGenderBar
# json |> sumAge |> builGenderBar
# json |> sumDs |> builGenderBar
# json |> sumYM |> builGenderBar

# json |> sumSex |> buildHorizonBar
# json |> sumAge |> buildHorizonBar
# json |> sumDs |> buildHorizonBar
# json |> sumYM |> buildHeatMap




## crossfilter

crx = crossfilter  json
allGrp = crx.groupAll!

sexDim = crx.dimension -> it.sex
ageDim = crx.dimension -> it.age_grp
p23Dim = crx.dimension -> it.p23_new
spdDim = crx.dimension -> it.sum_spend1000
cycDim = crx.dimension -> it.cycle
movDim = crx.dimension -> it.from_proid + "_" + it.po_id

sexGrp = sexDim.group -> it
ageGrp = ageDim.group -> it
p23Grp = p23Dim.group -> it
spdGrp = spdDim.group -> Math.round(it / 100) * 100
cycGrp = cycDim.group -> it
movGrp = movDim.group -> it


lsDim = [
	sexDim
	ageDim
	p23Dim
	spdDim
	cycDim
	movDim
]

lsGrp = [
	sexGrp
	ageGrp
	p23Grp
	spdGrp
	cycGrp
	movGrp
]

# lsExc = [ "sex" "age" "p23" "spd" "cyc" "mov"]
lsExc = [ "sex" "age" "p23" "spd" "cyc"]
lsFunc := lsExc.map ->
	(reBuildHorizonBar!
			.group (eval(it + "Grp")).all!
			.dimension (eval(it + "Dim")))



lsFunc.map -> it!

# op = (it, ->
	# console.log it
	# buildHorizonBar it
	


# .dimension(lsDim[i])	
# lsGrp.map((it,i)-> it.all! |> (reBuildHorizonBar!.group(_))!)


# console.log sexGrp.all!.top(Infinity).length

# console.log cycDim.filter("201401").top(Infinity).length
# console.log sexDim.filter("女").top(Infinity).length
# console.log sexDim.filter("男").top(Infinity).length
# console.log sexGrp.top(Infinity)
# console.log ageGrp.all!
# console.log p23Grp.all!





# charLS = [
# 	horChart!
# 		.dimension sexDim
# 		.group sexGrp
# ## to be continued here
# ]

# chart = d3.selectAll ".chart"
# 	.data charLS
# # 	.each -> 



# horChart!
# 	if not horChart.id then horChart.id = 0
# 	margin = {top: 10, right: 10, bottom: 20: left: 10}
# 	x = null
# 	y = d3.scale.linear!.range [100, 0]
# 	id = horChart.id++
# 	dimension = null
# 	group = null

# 	chart = (div)->
# 		width = x.range![1]
# 		height = y.range![0]

# 		y.domain [0, group.top 1 [0].value]

# 		div.each ->
# 			div = d3.select @
# 			g = div.select "g"

# 			if g.empty!
# 				g = div.append "svg"
# 					.attr {
# 						"width": width + margin.left + margin.right
# 						"height": height + margin.top + margin.bottom
# 					}
# 					.append "g"
# 					.attr {
# 						"transform": "translate(" + margin.left + "," + margin.top + ")"
# 					}

# 				g.selectAll ".bar"
# 				.data []




### this is only length of aggregate group; not correct size
d3.selectAll '#total'
	.text -> crx.size!





