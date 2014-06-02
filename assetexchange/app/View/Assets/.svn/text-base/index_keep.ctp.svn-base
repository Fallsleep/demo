<script>


$(document).ready(function(){
$.ajax({
    url: 'Assets/showAll',
    cache: false,
    type: 'POST',
    dataType: 'json',
    success: function (data) {
        $('#asset_index_view').html(process(data));
    }
});
});

function process(data){
	if ($.isEmptyObject(data)){
		return "<table><tr>沒有資料</tr></table>";
	}

	output = "<table>";
	//console.debug(data[0]);
	for (asset in data) {
		
		var img = false;

		switch(data[asset].Asset.status){
		case 'A': 
			data[asset].Asset.status = '未售出';
			break;
		case'IA':
			data[asset].Asset.status = '已售出';
			break;
	    }
		   
	    switch(data[asset].Asset.type){
		case '0':
			data[asset].Asset.type = '住宅';
			break;
		case '1':
			data[asset].Asset.type = '工商';
			break;
		case '2':
			data[asset].Asset.type = '商廈';
			break;
		case '3':
			data[asset].Asset.type = '店鋪';
			break;
		case '4':
			data[asset].Asset.type = '車位';
			break;
		case '5':
			data[asset].Asset.type = '其他';
			break;
	   }

	    switch(data[asset].Asset.has_rent){
		case false:
			data[asset].Asset.has_rent = '否';
			break;
		case true:
			data[asset].Asset.has_rent = '是';
			break;
	   }
			
		for (i in data[asset].AssetImg){
			if (data[asset].AssetImg[i].is_cover == 1 && !img){
				output += '<tr><td rowspan="6" width="180"><img src="' + data[asset].AssetImg[i].path +'" width="180"></td>';
				img = true;
			}
		}
		if (!img){
			output += '<tr><td rowspan="6" width="180"><img src="img/house.jpg" width="180"></td>';
		}

		
		
		output += '<th>編號:</th><td><a href="Assets/view/' + data[asset].Asset.id + '">' + data[asset].Asset.symbol + '</a></td><th>名稱:</th><td>' + data[asset].Asset.name + '</td></tr>';
		output += '<th>類型:</th><td>' + data[asset].Asset.type + '</td><th>狀態:</th><td>' + data[asset].Asset.status + '</td></tr>';
		output += '<th>地區:</th><td>' + data[asset].District.district_name + '</td><th>地址:</th><td>' + data[asset].Asset.address + '</td></tr>';
		output += '<th>面積:</th><td>' + data[asset].Asset.size + '</td><th>租金:</th><td>' + data[asset].Asset.rent + '</td></tr>';
		output += '<th>是否租出:</th><td>' + data[asset].Asset.has_rent + '</td><th>購入日期:</th><td>' + data[asset].Asset.buy_date + '</td></tr>';
		output += '<th>開售日期:</th><td>' + data[asset].Asset.open_date + '</td><th>截止日期:</th><td>' + data[asset].Asset.close_date + '</td></tr>';
		output += '<td><br><br></td>' + '<td><br><br></td>' + '<td><br><br></td>' + '<td><br><br></td>' + '<td><br><br></td>';
	}
	output += "</table>";
	
	return output;
}
</script>

<div id="asset_index_view">
	
</div>
<?php
//print_r($this->Session->read('Auth.User'));