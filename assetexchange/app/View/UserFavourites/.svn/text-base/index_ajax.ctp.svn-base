<!-- File: /app/View/UserFavourites/index.ctp -->

<script>
$(document).ajaxStart(function() {
   $("#progressbar").show();
 });
$(document).ajaxComplete(function() {
   $("#progressbar").hide();
 });
	 
$(document).ready(function() {
	$( "#progressbar" ).progressbar({
	      value: false
	    });
    
    load_favorite();

    setInterval(load_favorite, 1000*30);
});

function load_favorite(){
	$.ajax({
	    url: '<?php echo Router::url(array('controller' => 'UserFavourites', 'action' => 'getFavoriteAjax')) ?>',
	    cache: false,
	    type: 'POST',
	    dataType: 'json',
	    success: function (data) {
		    $('#update_div').html("<a class='refresh' onclick='load_favorite();' title='更新' style='display:inline'><span class='icon'>0</span>更新</a>時間（香港）: " + ($.isEmptyObject(data)?'':data.updated));
	        $('#favor_div').html(build_table_block(data));
	    }
	});
}

function build_table_block(data){
	output = "<table><col><col><col><col><col><col><col><col><col><col><col><col><col>";
	output += "<tr>";
	output += "<th>代號</th><th>股價</th><th colspan='2'>升趺及升跌幅%</th><th colspan='2'>是日最低價及最高價</th><th>成交量</th><th>持有股數</th><th>可動用股數</th><th>平均買入價</th><th colspan='2'></th>";

	$.each(data.data, function(index, favor) {
		if (!$.isEmptyObject(favor)){
			output += "<tr>";
			output += "<td><a href='<?php echo Router::url(array('controller' => 'assets', 'action' => 'view')) . '/'?>" + favor.asset_id + "'>" + favor.symbol + "</a></td>";
			output += "<td class='right'><b>" + Number(favor.last).toFixed(3) + "</b></td>";
			output += "<td class='right'><b>";
			if (favor.change != 0){
				var cp = ((favor.change > 0)?"rise":"fall");
				
				output += "<span class='" + cp + "'>" + Math.abs(favor.change) + "</span></td>";
			}
			else{
				output += "0";
			}
			output += "</b></td>";
			output += "<td class='right'><b>";
			if (favor.change_per != 0){
				var cp = ((favor.change_per > 0)?"rise":"fall");
				
				output += "<span class='" + cp + "'>" + Math.abs(favor.change_per).toFixed(2) + "%</span></td>";
			}
			else{
				output += "0.00%";
			}
			output += "</b></td>";
			output += "<td class='right'>" + Number(favor.day_low).toFixed(3) + "</td>";
			output += "<td class='right'>" + Number(favor.day_high).toFixed(3) + "</td>";
			output += "<td class='right'>" + favor.volume + "</td>";
			output += "<td class='right'>" + favor.user_volume + "</td>";
			output += "<td class='right'>" + favor.avail_volume + "</td>";
			output += "<td class='right'>" + favor.average_price + "</td>";
			output += "<td>";
			output += "<div class='buy_price'>" + ($.isEmptyObject(favor.closest_price.B)?"---":Number(favor.closest_price.B).toFixed(2)) + "</div>";
			output += "<a href='<?php echo Router::url(array('controller' => 'opens', 'action' => 'trade')) . '/'?>" + favor.asset_id + "'>買賣</a>";
			output += "<div class='sell_price'>" + ($.isEmptyObject(favor.closest_price.S)?"---":Number(favor.closest_price.S).toFixed(2)) + "</div>";
			output += "</td>";
			output += "<td><a href='<?php Router::url(array('controller' => 'UserFavourites', 'action' => 'delete')) .'/' ?>" + index + "'><span class='icon'>Â</span></a></td>";
			output += "</tr>";
		}
	});

	output += "</table>";
	return output;
}

</script>

<style>
.right { text-align: right; }
col { border-right: 1px solid #ddd; }
col:last-child { border-right: 0; }
#UserFavouriteIndexAjaxForm label { display: inline; margin-right: 5px;}
#UserFavouriteIndexAjaxForm input[type=text] { padding: 3px; margin-right: 5px; width: 100px; }
</style>

<div class="form-header">喜愛的物業 </div>
<div class="form-content">
	<table>
		<tr>
			<td>
				<div style="display: inline">
					<?php 
					echo $this->Form->create('UserFavourite', array('url' => array('controller' => 'UserFavourites', 'action' => 'add')));
					echo $this->Form->input('symbol', array('label' => '商品編號', 'type' => 'text', 'div' => false));
					echo $this->Form->end(array('label' => '新增', 'div' => false)); 
					?>
				</div>
			</td>
			<td class='right'>
				<div style="display: inline" id="update_div">
				</div>
			</td>
		</tr>
	</table>
	<div id="progressbar"></div>
	<div id="favor_div"></div>
</div>