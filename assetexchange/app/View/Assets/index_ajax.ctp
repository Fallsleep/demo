<script>

var top_list = {'rise':'最高升幅', 'fall':'最高跌幅','0':'熱門住宅','1':'熱門工商','2':'熱門商廈','3':'熱門店鋪','4':'熱門車位','5':'熱門其他'};

function load_top(key){
	$('#topload_'+key).addClass('loading');
	$.ajax({
	    url: '<?php echo Router::url(array('controller' => 'Assets', 'action' => 'getTopTenAjax')) ?>/' + key,
	    cache: false,
	    type: 'POST',
	    dataType: 'json',
	    success: function (data) { 
	       $('#top_' + key).html(build_table_block(data, key, top_list[key]));
	    }
	});
}

function init(key){
	$('#top_' + key).html(build_table_block(null, key, top_list[key]));
}

$(document).ready(function() {
	$.each(top_list, function(key, data) {
		init(key);
		load_top(key);
	});
});

function build_table_block(data, id, header){
	output = "<table class='asset'>";
	output += "<tr>";
	output += "<th>" + header + "<div id='topload_" + id + "' style='display:inline'>&nbsp;&nbsp;&nbsp;</div></th>";
	output += "<th colspan='3'><a class='refresh_" + id + "' onclick='load_top(\"" + id + "\");' title='更新' style='display:inline'><span class='icon'>0</span>更新</a>時間（香港）: " + ($.isEmptyObject(data)?'':data.updated) + "</th>";
	output += "</tr>";
	output += "<tr>";
	output += "<td>編號</td>";
	output += "<td>商品名稱</td>"
	output += "<td>單位市價（升跌%）</td>";
	output += "<td>操作</td>";
	output += "</tr>";

	if ($.isEmptyObject(data) || $.isEmptyObject(data.data)){
		for (var i=0;i<10;i++)
		{ 
			output += "<tr>";
			output += "<td>-</td>";
			output += "<td>-</td>";
			output += "<td>-</td>";
			output += "<td>-</td>";
			output += "</tr>";
		}
	}
	else{
		$.each(data.data, function(index, asset) {
			if (!$.isEmptyObject(asset)){
				output += "<tr>";
				output += "<td><a href='<?php echo Router::url(array('controller' => 'assets', 'action' => 'view')) . '/'?>" + asset.asset_id + "'>" + asset.symbol + "</a></td>";
				output += "<td>" + asset.name + "</td>";
				output += "<td>" + Number(asset.close_price).toFixed(3) + " ";
				if (asset.change_per != 0){
					var cp = ((asset.change_per > 0)?"rise":"fall");
					
					output += "(<span class='" + cp + "'>" + Math.abs(asset.change_per).toFixed(2) + "%</span>)</td>";
				}
				else{
					output += "(0.00%)";
				}
		
				output += "<td>";
				output += "<div class='buy_price'>" + ($.isEmptyObject(asset.closest_price.B)?"---":Number(asset.closest_price.B).toFixed(2)) + "</div>";
				output += "<a href='<?php echo Router::url(array('controller' => 'opens', 'action' => 'trade')) . '/'?>" + asset.asset_id + "'>買賣</a>";
				output += "<div class='sell_price'>" + ($.isEmptyObject(asset.closest_price.S)?"---":Number(asset.closest_price.S).toFixed(2)) + "</div>";
				output += "</td>";
				output += "</tr>";
			}else{
				output += "<tr>";
				output += "<td>-</td>";
				output += "<td>-</td>";
				output += "<td>-</td>";
				output += "<td>-</td>";
				output += "</tr>";
			}
		});
	}

	output += "</table>";
	return output;
}
</script>
	
<div id='assetwarpper'>
	<div id='leftcolumn'>
		<div id="top_rise"></div>
		<br><br>
		<div id="top_0"></div>
		<br><br>
		<div id="top_2"></div>
		<br><br>
		<div id="top_4"></div>
	</div>
	<div id='rightcolumn'>
		<div id="top_fall"></div>
		<?php 
			echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
		?>
		<br><br>
		<div id="top_1"></div>
		<?php 
			echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
		?>
		<br><br>
		<div id="top_3"></div>
		<?php 
			echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
		?>
		<br><br>
		<div id="top_5"></div>	
		<?php 
			echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
		?>
		<br><br>
	</div>
</div>
