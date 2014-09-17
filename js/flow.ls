{join, Str, fold1, obj-to-lists, lists-to-obj, flatten, unique, map, curry} = require "prelude-ls"

## actually don't know the value for male

ggl = {}
# ggl.headName = "地区"

ggl.margin = {top: 20, left: 50, right: 100, bottom: 50}
ggl.w = 300 - ggl.margin.left - ggl.margin.right
ggl.h = 800 - ggl.margin.top - ggl.margin.bottom

ggl.snky = {right: 100, bottom: 50}
ggl.paths = null

ggl.clrOrange = '#30B29C'
	# "rgb(253, 141, 60)"
ggl.clrRed = "rgb(215, 48, 39)"
ggl.clrBlue = "rgb(69, 117, 180)"

ggl.svgttlsize = 16

lsExc = null
lsFunc = null
sk = null

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
	"01":	"预保"
	"02":	"全科"
	"03":	"内科"
	"04":	"外科"
	"05":	"妇产"
	"06":	"妇保"
	"07":	"儿科"
	"08":	"儿外"
	"09":	"儿保"
	"10":	"眼科"
	"11":	"耳鼻"
	"12":	"口腔"
	"13":	"皮肤"
	"14":	"医美"
	"15":	"精神"
	"16":	"传染"
	"17":	"结核"
	"18":	"地方"
	"19":	"肿瘤"
	"20":	"急诊"
	"21":	"康复"
	"22":	"运动"
	"23":	"职业"
	"24":	"临终"
	"25":	"特军"
	"26":	"麻醉"
	"27":	"疼痛"
	"28":	"重症"
	"30":	"医学"
	"31":	"病理"
	"32":	"影像"
	"50":	"中医"
	"51":	"民医"
	"52":	"中西"
	"69":	"其他"
}

ggl.age_grptbl = {
	"0": "17 及以下"
	"1": "18 到 44"
	"2": "45 到 64"
	"3": "65 及以上"
}

ggl.sextbl = {
	"1": "男"
	"2": "女"
}

mkInterval = (list)->
	int = list[1] - list[0]
	unt = 1000
	lists-to-obj list, list.map (it, i)-> 
		if i is 0
			it + "-" + (it + Math.floor(int / 2) ) * unt
		else
			(it - Math.floor(int / 2)) * unt + "-" + (it + Math.floor(int / 2) ) * unt



ggl.spdtbl = [0 to 500 by 5] |> mkInterval 
	

ggl.smDifftbl = {
	true: "本地"
	false: "异地"
}


movGrp = null
movDim = null
sexDim = null

getY = (str)-> +(Str.take 4, str)
getM = (str)-> +(Str.drop 4, str)


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

		# if row.value < 0 or row.sum_spend1000 < 0 or row.count < 0 then console.log it

		# row.p23_new = ggl.p23tbl[row.p23_new]
		# row.age_grp = ggl.age_grptbl[row.age_grp]
		# row.sex = ggl.sextbl[row.sex]		

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

# cross2List = (jsonData)->

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
			"value": if row.value is 0 then 0.01 else row.value
			##workaround; or there will be error
		}

	rslt


##input: key: 360_440
##output: source: , target: 
key2ST = (ls)-> 
	ls.map -> 
		arr = it.key.split "_"
		{
			source: arr[0]
			target: arr[1]
			value: it.value
		}

ggl.sankey = d3.sankey!
	.size [ggl.w - ggl.snky.right, ggl.h - ggl.snky.bottom]
	.nodeWidth 15
	.nodePadding 10

ggl.path = ggl.sankey.reversibleLink!




buildMargin = ->
	rslt = {}
	# rslt.margin = {top: 30, left: 30, bottom: 30, right: 30}
	rslt.margin = {top: 10, left: 10, bottom: 10, right: 100}
	rslt.w = 300 - rslt.margin.left - rslt.margin.right
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


renderAll = ->
	lsFunc.map -> it.render!
	sk.render!


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
				"width": loc.w + loc.margin.left + loc.margin.right
				"height": loc.h + loc.margin.top + loc.margin.bottom
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
	loc.rectHeight = 10
	loc.rectMargin = 10
	loc.savedFilter = []
	loc.txtTbl = null
	loc.selector = ".sidechart"
	loc.sortFlag = false
	loc.fixSvgHeight = null

	dt = null
	sclBar = null
	ttl = null
	rct = null
	txt = null



##TODO multi criteria select doesn't seem to be working correctly
	toggleFilter = (flt)->
		idx = loc.savedFilter.indexOf flt
		if idx > -1 then loc.savedFilter.splice(idx, 1) else loc.savedFilter.push flt

		# console.log loc.savedFilter
		if loc.savedFilter.length > 0
			loc.dimension.filter(-> (loc.savedFilter.indexOf it) > -1 )

			dt
				.selectAll ".rct"+ (join "", (loc.savedFilter.map -> ":not(.rct" + it + ")" ))
				.style {
					"opacity": 0.2
				}
				
			dt
				.selectAll(join ",", (loc.savedFilter.map -> ".rct" + it ))
				.style {
					"opacity": 1
				}	
			
		else 
			loc.dimension.filter null

			dt
				.selectAll "rect"
				.style {
					"opacity": 0.7
				}	

	rctAttr = ->
		it.attr {
			"width": -> (sclBar it.value)
			"height": loc.rectHeight
			"x":(it, i)-> 0
			"y":(it, i)-> i * (loc.rectHeight + loc.rectMargin)
			"class": (it, i)-> "rct rct" + it.key 
		}
		.style {
			"fill": (it, i)-> ggl.clrOrange
		}
	txtAttr = ->
		it.attr {
			"x":(it, i)-> loc.w + loc.margin.left + loc.margin.right - 40
			"y":(it, i)-> i * (loc.rectHeight + loc.rectMargin) + 13
		}
		.style {
			opacity: (it, i)-> 
				w = (sclBar it.value)
				if w < 10 then (w / 10) + 0.1 else 1
			"text-anchor": "end"
		}
		.text (it, i)-> 
			if loc.txtTbl is null then it.key else loc.txtTbl[it.key]
			


	build = ->

		##auto adjust chart length
		if loc.fixSvgHeight is null
			loc.svg := (reBuildSvg!.h((loc.group.all!.length - 1)* (loc.rectHeight + loc.rectMargin) + loc.margin.top + loc.margin.bottom).selector loc.selector)!
		else 
			loc.svg := (reBuildSvg!.h( loc.fixSvgHeight ).selector loc.selector)!

		ttl := (loc.group.all!.map -> it.value) |> fold1 (+), _
		sclBar := d3.scale.linear!
			.domain [0, ttl]
			.range [0, loc.w]

		if loc.sortFlag
			dgrp = loc.svg
				.selectAll ".rect"
				.data (loc.group.top Infinity) , -> it.key

		else
			dgrp = loc.svg
				.selectAll ".rect"
				.data (loc.group.all!) , -> it.key


		dt := dgrp
			.enter!
			.append "g"
			.attr {
				"class": "horBar"
			}

		rct := dt.append "rect"
			.call rctAttr
			.style {
				opacity: 0.7
			}
			.on "mousedown", ->
				d3.select(@).data![0].key |> toggleFilter
				renderAll!

		txt := dt.append "text"
			.call txtAttr
			

	build.render = ->
		ttl := (loc.group.all!.map -> it.value) |> fold1 (+), _
		sclBar := d3.scale.linear!
			.domain [0, ttl]
			.range [0, loc.w]


		if loc.sortFlag
			rct
				.sort (a, b)-> b.value - a.value 
				.transition!
				.duration 1500
				.call rctAttr

			txt
				.sort (a, b)-> b.value - a.value 
				.transition!
				.duration 1500
				.call txtAttr

		else
			rct
				.transition!
				.call rctAttr

			txt
				.transition!
				.call txtAttr

	getSetter build, loc
	build


reBuildSankey = ->
	loc = {}
	loc.margin = {top: 50, left: 80, right: 10, bottom: 50}
	loc.w = 300 - loc.margin.left - loc.margin.right
	loc.h = 900 - loc.margin.top - loc.margin.bottom

	loc.group = null
	loc.rawData = null
	loc.dimension = null
	loc.path = null
	loc.paths = null
	loc.rect = null
	loc.sankey = null
	loc.texts = null
	loc.numbers = null
	loc.savedFilter = []


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

	tOrS = -> if it.sourceLinks.length > it.targetLinks.length then "s" else "t"

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


## do not support multiple filter here 

	toggleFilter = (flt)->
		# idx = loc.savedFilter.indexOf flt
		# if idx > -1 then loc.savedFilter.splice(idx, 1) else loc.savedFilter.push flt

		idx = loc.savedFilter.indexOf flt
		if idx > -1
			loc.savedFilter.splice(idx, 1)
		else
			loc.savedFilter[0] := flt


		if loc.savedFilter.length > 0
## interesting that this will needed, as function filter doesn't seem to clear all first.s
			loc.dimension.filter null 
			loc.dimension.filter(-> (loc.savedFilter.indexOf it) > -1 )	
		else 
			loc.dimension.filter null

		if loc.savedFilter.length > 0
			flt0 = (flt.split "_")[0]
			flt1 = (flt.split "_")[1]
			fltclass = ".s" + flt0 + "t" + flt1

			loc.svg
				.selectAll ".linkPath"+ (join "", (loc.savedFilter.map -> ":not(" + fltclass + ")" ))
				.call hideStyle
			loc.svg
				.selectAll(join ",", (loc.savedFilter.map -> fltclass ))
				.call highStyle


		else 
			loc.svg
				.selectAll ".linkPath"
				.call normStyle


	pathMouseover = ->
		# d3.select @ 
		# 	.call highStyle

		d3.selectAll ".ps" + it.source.name
			.text ~~(it.value / it.source.value * 100 ) + "%"

		d3.selectAll ".pt" + it.target.name
			.text ~~(it.value / it.target.value * 100 ) + "%"

	pathMouseout = ->
		# d3.select @ 
		# 	.call normStyle

		d3.selectAll ".ps" + it.source.name
			.text ""

		d3.selectAll ".pt" + it.target.name
			.text ""

	rectMouseover = ->
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

	rectMouseout = ->
		d3.selectAll ".linkPath"
			.call normStyle

		r = tOrSJson it

		it[r.k + "Links"]map (lk)->
			d3.selectAll ".p" + r.j + lk[r.l]name
				.text ""

	setTexts = ->
		it
			.attr {
				"x": -6
				"y": -> it.dy / 2
				"dy": "0.35em"
				"text-anchor": "end"
				"transform": -> "translate(" + it.x + "," + it.y + ")"
			}
			.style {
				"opacity": -> if it.dy < 10 then 0.2 else 1
			}

	setNumber = ->
		it
			.attr {
				"x": 45
				"y": -> it.dy / 2
				"dy": "0.35em"
				"text-anchor": "end"
				"transform": -> "translate(" + it.x + "," + it.y + ")"
				"class": -> "p" + (tOrS it)  + it.name
			}

	removePostFix = ->
		if it is undefined then return
		it.replace("市", "").replace("省", "")

	reInit = ->
		loc.group := (loc.rawData |> key2ST |> json2NodeLink )

		loc.sankey
			.nodes loc.group.nodes
			.links loc.group.links
			.layout 1

		loc.path := loc.sankey.reversibleLink!

	build = ->
		loc.svg := (reBuildSvg!
					.h loc.h
					.w loc.w
					.margin loc.margin
					.selector ".mainchart")!
		
		loc.sankey := d3.sankey!
			.size [loc.w - loc.margin.right, loc.h - loc.margin.bottom]
			.nodeWidth 15
			.nodePadding 10

		reInit!

		loc.paths := loc.svg
			.selectAll ".linkPath"
			.data loc.group.links
			.enter!
			.append "path"
			.attr {
				"fill": ggl.clrOrange			
				"d": loc.path 1
				"class": -> "t" + it.target.name + " s" + it.source.name + " linkPath " + "s" + it.source.name + "t" + it.target.name
			}
			.call normStyle
			.on "mouseover", pathMouseover
			.on "mouseout", pathMouseout
			.on "mousedown", ->
				o = d3.select(@).data![0]
				(o.source.name + "_" + o.target.name) |> toggleFilter
				renderAll!

		loc.rect := loc.svg
			.selectAll "sankeyRect"
			.data loc.group.nodes
			.enter!
			.append "rect"
			.attr {
				"x": -> it.x
				"y": -> it.y
				"height": -> it.dy
				"width": loc.sankey.nodeWidth!
				"fill": ggl.clrOrange
				"class": "sankeyRect"
			}
			.style {
				"opacity": 0.7
			}
			.on "mouseover", rectMouseover
			.on "mouseout", rectMouseout


		loc.texts := loc.svg
			.append "g"
			.selectAll ".node"
			.data loc.group.nodes
			.enter!
			.append "text"
			.call setTexts
			.text -> (ggl.nmtbl[it.name] |> removePostFix )

		loc.numbers := loc.svg
			.append "g"
			.selectAll ".node"
			.data loc.group.nodes
			.enter!
			.append "text"
			.call setNumber

		loc.svg
			.append "text"
			.text "归属"
			.attr {
				"x": -20
				"y": -20
			}
			.style {
				"font-size": ggl.svgttlsize + "px"
				"fill": ggl.clrOrange
			}

		loc.svg
			.append "text"
			.text "就诊"
			.attr {
				"x": 165
				"y": -20
			}
			.style {
				"font-size": ggl.svgttlsize + "px"
				"fill": ggl.clrOrange
			}


	build.render = ->
		reInit!

		loc.svg
			.selectAll "path"
			.data loc.group.links
			.transition!
			.duration 1500
			.attr {
				"d": loc.path 1
			}

		loc.texts
			.data loc.group.nodes
			.transition!
			.duration 1500
			.call setTexts

		loc.rect
			.data loc.group.nodes
			.transition!
			.duration 1500
			.attr {
				"y": -> it.y
				"height": -> it.dy
			}

		loc.numbers
			.data loc.group.nodes
			.transition!
			.duration 1500
			.call setNumber




	build.setGroup = (data)->
		loc.group := (data |> key2ST |> json2NodeLink )
		build

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



buildCrossfilter = (json)->
	## crossfilter
	crx = crossfilter  json
	allGrp = crx.groupAll!

	sexDim := crx.dimension -> it.sex
	ageDim = crx.dimension -> it.age_grp
	p23Dim = crx.dimension -> it.p23_new
	spdDim = crx.dimension -> it.sum_spend1000
	cycDim = crx.dimension -> it.cycle
	movDim := crx.dimension -> it.from_proid + "_" + it.po_id
	smDiffDim = crx.dimension -> (it.from_proid is it.po_id)

	sexGrp = sexDim.group(-> it).reduceSum( -> it.count )
	ageGrp = ageDim.group(-> it).reduceSum( -> it.count )
	p23Grp = p23Dim.group(-> it).reduceSum( -> it.count )
	spdGrp = spdDim.group(-> Math.round(it / 5) * 5).reduceSum( -> it.count )
	cycGrp = cycDim.group(-> it).reduceSum( -> it.count )
	movGrp := movDim.group(-> it).reduceSum( -> it.count )
	smDiffGrp = smDiffDim.group(-> it).reduceSum( -> it.count )


	# lsExc = [ "sex" "age" "p23" "spd" "cyc"]
	# lsTbl = ["sextbl", "age_grptbl", "p23tbl", null, null]

	lsExc = ["smDiff" "sex" "age" "p23" "spd" ]
	lsTbl = ["smDifftbl" "sextbl" "age_grptbl" "p23tbl" null ]

	lsFunc := lsExc.map (it, i)->
		txtFunc = (if lsTbl[i] is not null then ggl[lsTbl[i]] else null)
		p = (reBuildHorizonBar!
			.group (eval(it + "Grp"))
			.dimension (eval(it + "Dim"))
			.selector "." + it + "Chart"
			.txtTbl txtFunc
		)

		# if it is "spd" then p = p.selector ".numberchart"
		if it is "p23"
			p = p
				.sortFlag true
				.fixSvgHeight 410
	
		p!
		p

		


	sk := reBuildSankey!.rawData movGrp.all! .dimension movDim
	sk!


	# ### this is only length of aggregate group; not correct size
	# d3.selectAll '#total'
	# 	.text -> crx.size!





err, tsvBody <- d3.tsv "../transform_on_the_move/group/transfer_t30.tsv"

# json = tsvBody |> tsv2Json
tsvBody |> tsv2Json |> buildCrossfilter








