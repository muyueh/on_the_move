var ref$, join, Str, fold1, objToLists, listsToObj, flatten, unique, map, curry, ggl, lsExc, lsFunc, sk, movGrp, movDim, sexDim, getY, getM, tsv2Json, sumupST, sumupV, sumSex, sumAge, sumYM, sumDs, json2NodeLink, key2ST, buildMargin, buildSvg, renderAll, getSetter, reBuildSvg, reBuildHorizonBar, reBuildSankey, buildHeatMap, buildCrossfilter;
ref$ = require("prelude-ls"), join = ref$.join, Str = ref$.Str, fold1 = ref$.fold1, objToLists = ref$.objToLists, listsToObj = ref$.listsToObj, flatten = ref$.flatten, unique = ref$.unique, map = ref$.map, curry = ref$.curry;
ggl = {};
ggl.margin = {
  top: 20,
  left: 50,
  right: 100,
  bottom: 50
};
ggl.w = 400 - ggl.margin.left - ggl.margin.right;
ggl.h = 800 - ggl.margin.top - ggl.margin.bottom;
ggl.snky = {
  right: 100,
  bottom: 50
};
ggl.paths = null;
ggl.clrOrange = "rgb(253, 141, 60)";
ggl.clrRed = "rgb(215, 48, 39)";
ggl.clrBlue = "rgb(69, 117, 180)";
lsExc = null;
lsFunc = null;
sk = null;
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
ggl.sextbl = {
  "1": "男",
  "2": "女"
};
movGrp = null;
movDim = null;
sexDim = null;
getY = function(str){
  return +Str.take(4, str);
};
getM = function(str){
  return +Str.drop(4, str);
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
      "value": row.value === 0
        ? 0.01
        : row.value
    };
  });
  return rslt;
};
key2ST = function(ls){
  return ls.map(function(it){
    var arr;
    arr = it.key.split("_");
    return {
      source: arr[0],
      target: arr[1],
      value: it.value
    };
  });
};
ggl.sankey = d3.sankey().size([ggl.w - ggl.snky.right, ggl.h - ggl.snky.bottom]).nodeWidth(15).nodePadding(10);
ggl.path = ggl.sankey.reversibleLink();
buildMargin = function(){
  var rslt;
  rslt = {};
  rslt.margin = {
    top: 10,
    left: 10,
    bottom: 10,
    right: 10
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
renderAll = function(){
  lsFunc.map(function(it){
    return it.render();
  });
  return sk.render();
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
  var loc, dt, sclBar, ttl, rct, toggleFilter, rctAttr, txtAttr, build;
  loc = buildMargin();
  loc.group = null;
  loc.dimension = null;
  loc.rectHeight = 15;
  loc.rectMargin = 2;
  loc.savedFilter = [];
  loc.txtTbl = null;
  loc.selector = ".sidechart";
  dt = null;
  sclBar = null;
  ttl = null;
  rct = null;
  toggleFilter = function(flt){
    var idx;
    idx = loc.savedFilter.indexOf(flt);
    if (idx > -1) {
      loc.savedFilter.splice(idx, 1);
    } else {
      loc.savedFilter.push(flt);
    }
    if (loc.savedFilter.length > 0) {
      loc.dimension.filter(function(it){
        return loc.savedFilter.indexOf(it) > -1;
      });
      dt.selectAll(".rct" + join("", loc.savedFilter.map(function(it){
        return ":not(.rct" + it + ")";
      }))).style({
        "opacity": 0.2
      });
      return dt.selectAll(join(",", loc.savedFilter.map(function(it){
        return ".rct" + it;
      }))).style({
        "opacity": 1
      });
    } else {
      loc.dimension.filter(null);
      return dt.selectAll("rect").style({
        "opacity": 1
      });
    }
  };
  rctAttr = function(it){
    return it.attr({
      "width": function(it){
        var w;
        w = sclBar(it.value);
        if (w < 0) {
          return 0;
        } else {
          return w;
        }
      },
      "height": loc.rectHeight,
      "x": function(it, i){
        return 0;
      },
      "y": function(it, i){
        return i * (loc.rectHeight + loc.rectMargin);
      },
      "class": function(it, i){
        return "rct rct" + it.key;
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
        return loc.w - 80;
      },
      "y": function(it, i){
        return i * (loc.rectHeight + loc.rectMargin) + 13;
      }
    }).text(function(it, i){
      if (loc.txtTbl === null) {
        return it.key;
      } else {
        return loc.txtTbl[it.key];
      }
    });
  };
  build = function(){
    loc.svg = reBuildSvg().h(loc.group.all().length * (loc.rectHeight + loc.rectMargin) + loc.margin.top + loc.margin.bottom).selector(loc.selector)();
    ttl = fold1(curry$(function(x$, y$){
      return x$ + y$;
    }), loc.group.all().map(function(it){
      return it.value;
    }));
    sclBar = d3.scale.linear().domain([0, ttl]).range([0, loc.w]);
    dt = loc.svg.selectAll(".rect").data(loc.group.all()).enter().append("g").attr({
      "class": "horBar"
    });
    rct = dt.append("rect").call(rctAttr).on("mousedown", function(){
      toggleFilter(
      d3.select(this).data()[0].key);
      return renderAll();
    });
    return dt.append("text").call(txtAttr);
  };
  build.render = function(){
    ttl = fold1(curry$(function(x$, y$){
      return x$ + y$;
    }), loc.group.all().map(function(it){
      return it.value;
    }));
    sclBar = d3.scale.linear().domain([0, ttl]).range([0, loc.w]);
    return rct.transition().call(rctAttr);
  };
  getSetter(build, loc);
  return build;
};
reBuildSankey = function(){
  var loc, highStyle, normStyle, hideStyle, tOrS, tOrSJson, toggleFilter, pathMouseover, pathMouseout, rectMouseover, rectMouseout, setTexts, setNumber, removePostFix, reInit, build;
  loc = {};
  loc.margin = {
    top: 20,
    left: 50,
    right: 100,
    bottom: 50
  };
  loc.w = 400 - loc.margin.left - loc.margin.right;
  loc.h = 800 - loc.margin.top - loc.margin.bottom;
  loc.group = null;
  loc.rawData = null;
  loc.dimension = null;
  loc.path = null;
  loc.paths = null;
  loc.rect = null;
  loc.sankey = null;
  loc.texts = null;
  loc.numbers = null;
  loc.savedFilter = [];
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
  tOrS = function(it){
    if (it.sourceLinks.length > it.targetLinks.length) {
      return "s";
    } else {
      return "t";
    }
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
  toggleFilter = function(flt){
    var idx, flt0, flt1, fltclass;
    idx = loc.savedFilter.indexOf(flt);
    if (idx > -1) {
      loc.savedFilter.splice(idx, 1);
    } else {
      loc.savedFilter[0] = flt;
    }
    if (loc.savedFilter.length > 0) {
      loc.dimension.filter(null);
      loc.dimension.filter(function(it){
        return loc.savedFilter.indexOf(it) > -1;
      });
    } else {
      loc.dimension.filter(null);
    }
    if (loc.savedFilter.length > 0) {
      flt0 = flt.split("_")[0];
      flt1 = flt.split("_")[1];
      fltclass = ".s" + flt0 + "t" + flt1;
      loc.svg.selectAll(".linkPath" + join("", loc.savedFilter.map(function(){
        return ":not(" + fltclass + ")";
      }))).call(hideStyle);
      return loc.svg.selectAll(join(",", loc.savedFilter.map(function(){
        return fltclass;
      }))).call(highStyle);
    } else {
      return loc.svg.selectAll(".linkPath").call(normStyle);
    }
  };
  pathMouseover = function(it){
    d3.selectAll(".ps" + it.source.name).text(~~(it.value / it.source.value * 100) + "%");
    return d3.selectAll(".pt" + it.target.name).text(~~(it.value / it.target.value * 100) + "%");
  };
  pathMouseout = function(it){
    d3.selectAll(".ps" + it.source.name).text("");
    return d3.selectAll(".pt" + it.target.name).text("");
  };
  rectMouseover = function(it){
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
  };
  rectMouseout = function(it){
    var r;
    d3.selectAll(".linkPath").call(normStyle);
    r = tOrSJson(it);
    return it[r.k + "Links"].map(function(lk){
      return d3.selectAll(".p" + r.j + lk[r.l].name).text("");
    });
  };
  setTexts = function(it){
    return it.attr({
      "x": -6,
      "y": function(it){
        return it.dy / 2;
      },
      "dy": "0.35em",
      "text-anchor": "end",
      "transform": function(it){
        return "translate(" + it.x + "," + it.y + ")";
      }
    }).style({
      "opacity": function(it){
        if (it.dy < 10) {
          return 0.2;
        } else {
          return 1;
        }
      }
    });
  };
  setNumber = function(it){
    return it.attr({
      "x": 45,
      "y": function(it){
        return it.dy / 2;
      },
      "dy": "0.35em",
      "text-anchor": "end",
      "transform": function(it){
        return "translate(" + it.x + "," + it.y + ")";
      },
      "class": function(it){
        return "p" + tOrS(it) + it.name;
      }
    });
  };
  removePostFix = function(it){
    if (it === undefined) {
      return;
    }
    return it.replace("市", "").replace("省", "");
  };
  reInit = function(){
    loc.group = json2NodeLink(
    key2ST(
    loc.rawData));
    loc.sankey.nodes(loc.group.nodes).links(loc.group.links).layout(1);
    return loc.path = loc.sankey.reversibleLink();
  };
  build = function(){
    loc.svg = reBuildSvg().h(loc.h).w(loc.w).margin(loc.margin).selector(".mainchart")();
    loc.sankey = d3.sankey().size([loc.w - loc.margin.right, loc.h - loc.margin.bottom]).nodeWidth(15).nodePadding(10);
    reInit();
    loc.paths = loc.svg.selectAll(".linkPath").data(loc.group.links).enter().append("path").attr({
      "fill": ggl.clrOrange,
      "d": loc.path(1),
      "class": function(it){
        return "t" + it.target.name + " s" + it.source.name + " linkPath " + "s" + it.source.name + "t" + it.target.name;
      }
    }).call(normStyle).on("mouseover", pathMouseover).on("mouseout", pathMouseout).on("mousedown", function(){
      var o;
      o = d3.select(this).data()[0];
      toggleFilter(
      o.source.name + "_" + o.target.name);
      return renderAll();
    });
    loc.rect = loc.svg.selectAll("sankeyRect").data(loc.group.nodes).enter().append("rect").attr({
      "x": function(it){
        return it.x;
      },
      "y": function(it){
        return it.y;
      },
      "height": function(it){
        return it.dy;
      },
      "width": loc.sankey.nodeWidth(),
      "fill": ggl.clrOrange,
      "class": "sankeyRect"
    }).style({
      "opacity": 0.7
    }).on("mouseover", rectMouseover).on("mouseout", rectMouseout);
    loc.texts = loc.svg.append("g").selectAll(".node").data(loc.group.nodes).enter().append("text").call(setTexts).text(function(it){
      return removePostFix(
      ggl.nmtbl[it.name]);
    });
    return loc.numbers = loc.svg.append("g").selectAll(".node").data(loc.group.nodes).enter().append("text").call(setNumber);
  };
  build.render = function(){
    reInit();
    loc.svg.selectAll("path").data(loc.group.links).transition().duration(1500).attr({
      "d": loc.path(1)
    });
    loc.texts.data(loc.group.nodes).transition().duration(1500).call(setTexts);
    loc.rect.data(loc.group.nodes).transition().duration(1500).attr({
      "y": function(it){
        return it.y;
      },
      "height": function(it){
        return it.dy;
      }
    });
    return loc.numbers.data(loc.group.nodes).transition().duration(1500).call(setNumber);
  };
  build.setGroup = function(data){
    loc.group = json2NodeLink(
    key2ST(
    data));
    return build;
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
buildCrossfilter = function(json){
  var crx, allGrp, ageDim, p23Dim, spdDim, cycDim, sexGrp, ageGrp, p23Grp, spdGrp, cycGrp, lsExc, lsTbl;
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
  }).reduceSum(function(it){
    return it.count;
  });
  ageGrp = ageDim.group(function(it){
    return it;
  }).reduceSum(function(it){
    return it.count;
  });
  p23Grp = p23Dim.group(function(it){
    return it;
  }).reduceSum(function(it){
    return it.count;
  });
  spdGrp = spdDim.group(function(it){
    return Math.round(it / 1000) * 1000;
  }).reduceSum(function(it){
    return it.count;
  });
  cycGrp = cycDim.group(function(it){
    return it;
  }).reduceSum(function(it){
    return it.count;
  });
  movGrp = movDim.group(function(it){
    return it;
  }).reduceSum(function(it){
    return it.count;
  });
  lsExc = ["sex", "age", "p23", "spd"];
  lsTbl = ["sextbl", "age_grptbl", "p23tbl", null];
  lsFunc = lsExc.map(function(it, i){
    var txtFunc, p;
    txtFunc = lsTbl[i] !== null ? ggl[lsTbl[i]] : null;
    p = reBuildHorizonBar().group(eval(it + "Grp")).dimension(eval(it + "Dim")).txtTbl(txtFunc);
    if (it === "spd") {
      p = p.selector(".numberchart");
    }
    p();
    return p;
  });
  sk = reBuildSankey().rawData(movGrp.all()).dimension(movDim);
  return sk();
};
d3.tsv("../transform/group/transfer_t10.tsv", function(err, tsvBody){
  return buildCrossfilter(
  tsv2Json(
  tsvBody));
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