var ref$, Str, fold1, objToLists, listsToObj, flatten, unique, map, curry, ggl, getY, getM, dragMove, tsv2Json, sumupST, sumupV, sumSex, sumAge, sumYM, sumDs, json2NodeLink, buildSankey, buildMargin, buildSvg, builGenderBar, renderAll, getSetter, reBuildSvg, reBuildHorizonBar, buildHeatMap, lsExc, lsFunc;
ref$ = require("prelude-ls"), Str = ref$.Str, fold1 = ref$.fold1, objToLists = ref$.objToLists, listsToObj = ref$.listsToObj, flatten = ref$.flatten, unique = ref$.unique, map = ref$.map, curry = ref$.curry;
ggl = {};
ggl.margin = {
  top: 20,
  left: 50,
  right: 100,
  bottom: 50
};
ggl.w = 300 - ggl.margin.left - ggl.margin.right;
ggl.h = 800 - ggl.margin.top - ggl.margin.bottom;
ggl.snky = {
  right: 100,
  bottom: 50
};
ggl.paths = null;
ggl.clrOrange = "rgb(253, 141, 60)";
ggl.clrRed = "rgb(215, 48, 39)";
ggl.clrBlue = "rgb(69, 117, 180)";
ggl.nmtbl = {
  "110": "北京市",
  "120": "天津市",
  "130": "河北省",
  "140": "山西省",
  "150": "内蒙古",
  "210": "辽宁省",
  "220": "吉林省",
  "230": "黑龙江",
  "310": "上海市",
  "320": "江苏省",
  "330": "浙江省",
  "340": "安徽省",
  "350": "福建省",
  "360": "江西省",
  "370": "山东省",
  "410": "河南省",
  "420": "湖北省",
  "430": "湖南省",
  "440": "广东省",
  "450": "广西省",
  "460": "海南省",
  "500": "重庆市",
  "510": "四川省",
  "520": "贵州省",
  "530": "云南省",
  "540": "西藏",
  "610": "陕西省",
  "620": "甘肃省",
  "630": "青海省",
  "640": "宁夏",
  "650": "新疆兵团"
};
ggl.p23tbl = {
  "01": "预防保健科",
  "02": "全科医疗科",
  "03": "内科",
  "04": "外科",
  "05": "妇产科",
  "06": "妇女保健科",
  "07": "儿科",
  "08": "小儿外科",
  "09": "儿童保健科",
  "10": "眼科",
  "11": "耳鼻咽喉科",
  "12": "口腔科",
  "13": "皮肤科",
  "14": "医疗美容科",
  "15": "精神科",
  "16": "传染科",
  "17": "结核病科",
  "18": "地方病科",
  "19": "肿瘤科",
  "20": "急诊医学科",
  "21": "康复医学科",
  "22": "运动医学科",
  "23": "职业病科",
  "24": "临终关怀科",
  "25": "特种医学与军事医学科",
  "26": "麻醉科",
  "27": "疼痛科",
  "28": "重症医学科",
  "30": "医学检验科",
  "31": "病理科",
  "32": "医学影像科",
  "50": "中医科",
  "51": "民族医学科",
  "52": "中西医结合科",
  "69": "其他业务科室"
};
ggl.age_grptbl = {
  "0": "17 及以下",
  "1": "18 到 44",
  "2": "45 到 64",
  "3": "65 及以上"
};
ggl.age_sextbl = {
  "1": "男",
  "2": "女"
};
getY = function(str){
  return +Str.take(4, str);
};
getM = function(str){
  return +Str.drop(4, str);
};
dragMove = function(it){
  d3.select(this).attr({
    "transform": "translate(" + it.x + "," + (it.y = Math.max(0, Math.min(ggl.h - it.dy, d3.event.y))) + ")"
  });
  ggl.sankey.relayout();
  return ggl.paths.attr({
    "d": ggl.path(1)
  });
};
tsv2Json = function(tsvData){
  var jsonData;
  jsonData = [];
  tsvData.filter(function(row, i){
    if (row.from_proid === "000" || row.from_proid === "650" || row.po_id === "650" || row.sex === "-1" || getY(row.cycle) === 2010 || getY(row.cycle) === 2012) {
      return false;
    }
    row.sum_spend1000 = +row.sum_spend1000;
    row.count = +row.count;
    row.source = row.from_proid;
    row.target = row.po_id;
    row.value = row.count;
    row.p23_new = ggl.p23tbl[row.p23_new];
    row.age_grp = ggl.age_grptbl[row.age_grp];
    row.sex = ggl.age_sextbl[row.sex];
    return jsonData.push(row);
  });
  return jsonData;
};
sumupST = function(jsonData){
  var tbl;
  tbl = {};
  jsonData.map(function(row, i){
    var str;
    str = row.source + "_" + row.target;
    if (tbl[str] === undefined) {
      tbl[str] = {};
      tbl[str].source = row.source;
      tbl[str].target = row.target;
      tbl[str].value = 0;
    }
    return tbl[str].value += row.value;
  });
  return objToLists(tbl)[1];
};
sumupV = curry(function(against, jsonData){
  var tbl;
  tbl = {};
  jsonData.map(function(row, i){
    var str;
    str = row[against];
    if (tbl[str] === undefined) {
      tbl[str] = {};
      tbl[str].name = row[against];
      tbl[str].value = 0;
    }
    return ++tbl[str].value;
  });
  return objToLists(tbl)[1];
});
sumSex = sumupV("sex");
sumAge = sumupV("age_grp");
sumYM = sumupV("cycle");
sumDs = sumupV("p23_new");
json2NodeLink = function(jsonData){
  var rslt, lsnames, tbl;
  rslt = {};
  lsnames = unique(
  flatten(
  jsonData.map(function(it){
    return ["s-" + it.source, "t-" + it.target];
  })));
  rslt.nodes = map(function(it){
    return {
      name: it.split("-")[1]
    };
  })(
  lsnames);
  tbl = listsToObj(lsnames, (function(){
    var i$, to$, results$ = [];
    for (i$ = 0, to$ = lsnames.length - 1; i$ <= to$; ++i$) {
      results$.push(i$);
    }
    return results$;
  }()));
  rslt.links = jsonData.map(function(row){
    return {
      "source": tbl["s-" + row.source],
      "target": tbl["t-" + row.target],
      "value": row.value
    };
  });
  return rslt;
};
ggl.sankey = d3.sankey().size([ggl.w - ggl.snky.right, ggl.h - ggl.snky.bottom]).nodeWidth(15).nodePadding(10);
ggl.path = ggl.sankey.reversibleLink();
buildSankey = function(data){
  var svg, linkEnter, highStyle, normStyle, hideStyle, node, tOrS, tOrSJson;
  ggl.sankey.nodes(data.nodes).links(data.links).layout(1);
  svg = d3.select("body").select(".mainchart").append("svg").attr({
    "width": ggl.w,
    "height": ggl.h
  }).append("g").attr({
    "transform": "translate(" + ggl.margin.left + "," + ggl.margin.top + ")"
  });
  linkEnter = svg.append("g").selectAll(".linkGrp").data(data.links).enter().append("g").attr({
    "class": function(){
      return "linkGrp";
    }
  }).sort(function(a, b){
    return b.dy - a.dy;
  });
  highStyle = function(it){
    return it.style({
      "opacity": 0.8
    });
  };
  normStyle = function(it){
    return it.style({
      "opacity": 0.4
    });
  };
  hideStyle = function(it){
    return it.style({
      "opacity": 0.1
    });
  };
  ggl.paths = linkEnter.append("path").attr({
    "fill": ggl.clrOrange,
    "d": ggl.path(1),
    "class": function(it){
      return "t" + it.target.name + " s" + it.source.name + " linkPath";
    }
  }).call(normStyle).on("mouseover", function(it){
    d3.select(this).call(highStyle);
    d3.selectAll(".ps" + it.source.name).text(~~(it.value / it.source.value * 100) + "%");
    return d3.selectAll(".pt" + it.target.name).text(~~(it.value / it.target.value * 100) + "%");
  }).on("mouseout", function(it){
    d3.select(this).call(normStyle);
    d3.selectAll(".ps" + it.source.name).text("");
    return d3.selectAll(".pt" + it.target.name).text("");
  });
  node = svg.append("g").selectAll(".node").data(data.nodes).enter().append("g").attr({
    "class": "node",
    "transform": function(it){
      return "translate(" + it.x + "," + it.y + ")";
    }
  }).call(d3.behavior.drag().origin(function(it){
    return it;
  }).on("dragstart", function(){
    return this.parentNode.appendChild(this);
  }).on("drag", dragMove));
  tOrS = function(it){
    return it.sourceLinks.length > it.targetLinks.length ? "s" : "t";
  };
  tOrSJson = function(it){
    if (it.sourceLinks.length < it.targetLinks.length) {
      return {
        i: "t",
        j: "s",
        k: "target",
        l: "source"
      };
    } else {
      return {
        i: "s",
        j: "t",
        k: "source",
        l: "target"
      };
    }
  };
  node.append("rect").attr({
    "height": function(it){
      return it.dy;
    },
    "width": ggl.sankey.nodeWidth(),
    "fill": ggl.clrOrange
  }).on("mouseover", function(it){
    var r;
    d3.selectAll(".linkPath:not(" + tOrS(it) + it.name + ")").call(hideStyle);
    d3.selectAll("." + tOrS(it) + it.name).call(highStyle);
    r = tOrSJson(it);
    return it[r.k + "Links"].map(function(lk){
      return d3.selectAll(".p" + r.j + lk[r.l].name).text(function(){
        var s;
        s = ~~(lk.value / lk[r.l].value * 100);
        return s === 0
          ? ""
          : s + "%";
      });
    });
  }).on("mouseout", function(it){
    var r;
    d3.selectAll(".linkPath").call(normStyle);
    r = tOrSJson(it);
    return it[r.k + "Links"].map(function(lk){
      return d3.selectAll(".p" + r.j + lk[r.l].name).text("");
    });
  });
  node.append("text").attr({
    "x": -6,
    "y": function(it){
      return it.dy / 2;
    },
    "dy": "0.35em",
    "text-anchor": "end",
    "transform": null
  }).text(function(it){
    return ggl.nmtbl[it.name];
  });
  return node.append("text").attr({
    "x": 45,
    "y": function(it){
      return it.dy / 2;
    },
    "dy": "0.35em",
    "text-anchor": "end",
    "transform": null,
    "class": function(it){
      return "p" + tOrS(it) + it.name;
    }
  });
};
buildMargin = function(){
  var rslt;
  rslt = {};
  rslt.margin = {
    top: 30,
    left: 30,
    bottom: 30,
    right: 30
  };
  rslt.w = 400 - rslt.margin.left - rslt.margin.right;
  rslt.h = 200 - rslt.margin.top - rslt.margin.bottom;
  return rslt;
};
buildSvg = function(margin){
  return d3.select("body").select(".sidechart").append("svg").attr({
    "width": margin.w,
    "height": margin.h
  }).append("g").attr({
    "transform": "translate(" + margin.margin.left + "," + margin.margin.top + ")"
  });
};
builGenderBar = function(data){
  var bar, svg, ttl, sclBar, offset, clr, rct;
  bar = buildMargin();
  svg = buildSvg(bar);
  ttl = fold1(curry$(function(x$, y$){
    return x$ + y$;
  }), data.map(function(it){
    return it.value;
  }));
  sclBar = d3.scale.linear().domain([0, ttl]).range([0, bar.w]);
  offset = 0;
  data = data.filter(function(it, i){
    it.x0 = offset;
    return offset += sclBar(it.value);
  });
  clr = d3.scale.category10();
  return rct = svg.selectAll(".rect").data(data).each(function(){}).enter().append("rect").attr({
    "width": function(it){
      return sclBar(it.value);
    },
    "height": 15,
    "x": function(it, i){
      return it.x0;
    }
  }).style({
    "fill": function(it, i){
      return clr(i);
    }
  }).append("title").text(function(it, i){
    return it.name;
  });
};
renderAll = function(){
  return lsFunc.map(function(it){
    return it.render();
  });
};
getSetter = function(build, loc){
  var i$, results$ = [];
  for (i$ in loc) {
    results$.push((fn$.call(this, i$)));
  }
  return results$;
  function fn$(it){
    return build[it] = function(v){
      if (arguments.length === 0) {
        return loc[it];
      } else {
        loc[it] = v;
        return build;
      }
    };
  }
};
reBuildSvg = function(){
  var loc, build;
  loc = buildMargin();
  loc.selector = ".sidechart";
  build = function(){
    return d3.select("body").select(loc.selector).append("svg").attr({
      "width": loc.w,
      "height": loc.h
    }).append("g").attr({
      "transform": "translate(" + loc.margin.left + "," + loc.margin.top + ")"
    });
  };
  getSetter(build, loc);
  return build;
};
reBuildHorizonBar = function(){
  var loc, dt, sclBar, ttl, rct, rctAttr, txtAttr, build;
  loc = buildMargin();
  loc.group = null;
  loc.dimension = null;
  loc.rectHeight = 15;
  loc.rectMargin = 2;
  dt = null;
  sclBar = null;
  ttl = null;
  rct = null;
  rctAttr = function(it){
    return it.attr({
      "width": function(it){
        return sclBar(it.value);
      },
      "height": loc.rectHeight,
      "x": function(it, i){
        return 0;
      },
      "y": function(it, i){
        return i * (loc.rectHeight + loc.rectMargin);
      }
    }).style({
      "fill": function(it, i){
        return ggl.clrOrange;
      }
    });
  };
  txtAttr = function(it){
    return it.attr({
      "x": function(it, i){
        return 100;
      },
      "y": function(it, i){
        return i * (loc.rectHeight + loc.rectMargin) + 13;
      }
    }).text(function(it, i){
      return it.key;
    });
  };
  build = function(){
    loc.svg = reBuildSvg().h(loc.group.length * (loc.rectHeight + loc.rectMargin) + loc.margin.top + loc.margin.bottom);
    ttl = fold1(curry$(function(x$, y$){
      return x$ + y$;
    }), loc.group.map(function(it){
      return it.value;
    }));
    sclBar = d3.scale.linear().domain([0, ttl]).range([0, loc.w]);
    dt = loc.svg().selectAll(".rect").data(loc.group).enter().append("g").attr({
      "class": "horBar"
    });
    rct = dt.append("rect").call(rctAttr).on("mousedown", function(){
      var k;
      k = d3.select(this).data()[0].key;
      loc.dimension.filter(k);
      return renderAll();
    });
    return dt.append("text").call(txtAttr);
  };
  build.render = function(){
    console.log(loc.group);
    return rct.transition().call(rctAttr);
  };
  getSetter(build, loc);
  return build;
};
buildHeatMap = function(data){
  var heat, svg, sclHeat;
  heat = buildMargin();
  heat.height = 400;
  heat.rect = {};
  heat.rect.width = 10;
  heat.rect.height = 10;
  heat.rect.margin = 5;
  heat.rect.unit = heat.rect.width + heat.rect.margin;
  svg = buildSvg(heat);
  sclHeat = d3.scale.linear().domain(d3.extent(data, function(it){
    return it.value;
  })).range([0, 1]);
  return svg.selectAll("rect").data(data).enter().append("rect").attr({
    "width": heat.rect.width,
    "height": heat.rect.height,
    "x": function(it, i){
      return ((getM(it.name) - 1) % 12) * heat.rect.unit;
    },
    "y": function(it, i){
      return ~~(getY(it.name) - 2009) * heat.rect.unit;
    }
  }).style({
    "opacity": function(it, i){
      return sclHeat(it.value);
    },
    "fill": function(it, i){
      return ggl.clrOrange;
    }
  });
};
lsExc = null;
lsFunc = null;
d3.tsv("../transform/group/transfer_t10.tsv", function(err, tsvBody){
  var json, crx, allGrp, sexDim, ageDim, p23Dim, spdDim, cycDim, movDim, sexGrp, ageGrp, p23Grp, spdGrp, cycGrp, movGrp, lsDim, lsGrp, lsExc;
  json = tsv2Json(
  tsvBody);
  buildSankey(
  json2NodeLink(
  sumupST(
  json)));
  crx = crossfilter(json);
  allGrp = crx.groupAll();
  sexDim = crx.dimension(function(it){
    return it.sex;
  });
  ageDim = crx.dimension(function(it){
    return it.age_grp;
  });
  p23Dim = crx.dimension(function(it){
    return it.p23_new;
  });
  spdDim = crx.dimension(function(it){
    return it.sum_spend1000;
  });
  cycDim = crx.dimension(function(it){
    return it.cycle;
  });
  movDim = crx.dimension(function(it){
    return it.from_proid + "_" + it.po_id;
  });
  sexGrp = sexDim.group(function(it){
    return it;
  });
  ageGrp = ageDim.group(function(it){
    return it;
  });
  p23Grp = p23Dim.group(function(it){
    return it;
  });
  spdGrp = spdDim.group(function(it){
    return Math.round(it / 100) * 100;
  });
  cycGrp = cycDim.group(function(it){
    return it;
  });
  movGrp = movDim.group(function(it){
    return it;
  });
  lsDim = [sexDim, ageDim, p23Dim, spdDim, cycDim, movDim];
  lsGrp = [sexGrp, ageGrp, p23Grp, spdGrp, cycGrp, movGrp];
  lsExc = ["sex", "age", "p23", "spd", "cyc"];
  lsFunc = lsExc.map(function(it){
    return reBuildHorizonBar().group(eval(it + "Grp").all()).dimension(eval(it + "Dim"));
  });
  lsFunc.map(function(it){
    return it();
  });
  return d3.selectAll('#total').text(function(){
    return crx.size();
  });
});
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}