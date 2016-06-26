<#ftl encoding='shift-jis'>
<#include "common_header.ftl">
<body>

<div class="main">
  <#if context.paramSentence??>
    <p>以下の文章のワードクラウドを表示しています。</p>
    <p class="param_sentence">
      ${context.paramSentence?html}
    </p>
  </#if>

  <p align="center">
	<svg/>
  </p>

  <div class="input_area">
    <form method="get" action="/wc" accept-charset="UTF-8">
	  <textArea class="input_box" name="sentence" maxlength="10000" 
	    placeholder="ここに文章を入力してください。"></textArea>
	  <input type="submit" name="送信">
    </form>
  </div>
</div>

<#if context.wcData??>
	<script src="assets/javascripts/d3-cloud/d3.layout.cloud.js"></script>
	<script>
	var w = ${context.width?c};
	var h = ${context.height?c};
	d3.select('svg').append('text')
	.attr({
		x:50,
		y:50,
		fill:"black",
		"font-size":40
	})
	.text('Loading...')

	    var data = ${context.wcData};
	    //処理wordを1200件に絞る
	    data = data.splice(0, 1200);

	    var random = d3.random.irwinHall(2)

	    var countMax = d3.max(data, function(d){ return d.count} );
	    var sizeScale = d3.scale.linear().domain([0, countMax]).range([10, 100])
	    var colorScale = d3.scale.category20();

	    var words = data.map(function(d) {
	        return {
	        text: d.word,
	        //頻出カウントを文字サイズに反映
	        size: sizeScale(d.count)
	        };
	    });

	    d3.layout.cloud().size([w, h])
	        .words(words)
	        //ランダムに文字を90度回転
	        .rotate(function() { return Math.round(1-random()) * 90; })
	        .font("Impact")
	        .fontSize(function(d) { return d.size; })
	        .on("end", draw) //描画関数の読み込み
	        .start();

	    //wordcloud 描画
	    function draw(words) {
	    	// 最初に表示したロード中の表記を消す
			d3.selectAll('text').remove();
	        d3.select("svg")
	        .attr({
	            "width": w,
	            "height": h
	        })
	        .append("g")
	        .attr("transform", "translate(150,150)")
	        .selectAll("text")
	        .data(words)
	        .enter()
	        .append("text")
	        .style({
	            "font-family": "Impact",
	            "font-size":function(d) { return d.size + "px"; },
	            "fill": function(d, i) { return colorScale(i); }
	        })
	        .attr({
	            "text-anchor":"middle",
	            "transform": function(d) {
	                return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
	            }
	        })
	        .text(function(d) { return d.text; });
	    }
	</script>
</#if>
    </body>
</html>
