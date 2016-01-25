Number.prototype.formatMoney = function(c, d, t){
  var n = this, 
  c = isNaN(c = Math.abs(c)) ? 2 : c, 
  d = d == undefined ? "." : d, 
  t = t == undefined ? "," : t, 
  s = n < 0 ? "-" : "", 
  i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", 
  j = (j = i.length) > 3 ? j % 3 : 0;
  return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};

function updateDataset(legendLi, chart, label) {
  var store = chart.store;
  var exists = false;
  for (var i = 0; i < store.length; i++) {
    if (store[i][0] === label) {
      exists = true;
      chart.datasets.push(store.splice(i, 1)[0][1]);
      legendLi.fadeTo("slow", 1);
    }
  }
  if (!exists) {
    for (var i = 0; i < chart.datasets.length; i++) {
      if (chart.datasets[i].label === label) {
        chart.store.push([label, chart.datasets.splice(i, 1)[0]]);
        legendLi.fadeTo("slow", 0.33);
      }
    }
  }
  chart.update();
}
Chart.defaults.global.responsive = true;
