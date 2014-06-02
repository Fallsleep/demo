<!-- File: /app/View/Users/accounthistory.ctp -->

<?php 
	foreach ($user['Open'] as $open) {
		;
	}
	foreach ($user['UserAsset'] as $userasset) {
		;
	}
?>

<div class="form-header">帳戶記錄</div>  
<div class="form-content"  id="asset-info-content">
<table>   
    <tr>
		<th>帳戶</th>
		<td colspan="8"><?=$user['User']['id']?></td>
		<th>收入</th>
		<td colspan="8"><?=$user['User']['balance']?></td>	
	</tr>	
<tr></tr>
    <tr><th colspan="16"><br><br>當前交易</th></tr> 
     <tr>
         <th>客戶編號</th>
         <td colspan="8"><?=$open['user_id']?></td>
         <th>類型</th>
         <td colspan="8"><?=$open['type']?></td>
     </tr>
     <tr>    
         <th>商品編號</th>
         <td colspan="8"><?=$open['asset_id']?></td>
         <th>手數</th>
         <td colspan="8"><?=$open['volume']?$open['volume']:'-';?></td>
     </tr>
     <tr>    
         <th>起賣價格</th>
         <td colspan="8"><?=$open['open_price']?$open['open_price']:'-';?></td> 
         <td></td><td></td>      
     </tr>
     <tr>    
         <th>起賣日期</th>   
            <td colspan="8"><?=$open['open_time']?></td>      
         <th>有效日期 </th>
            <td colspan="8"><?=$open['close_time']?></td>
     </tr>
     <tr>    
         <th>賣出股份</th>
            <td colspan="8"><?=$open['fulfil_volume']?$open['fulfil_volume']:'-';?></td>
         <th>狀態 </th>
            <td colspan="8"><?=$open['status']?></td>
     </tr>
     <tr>    
         <th>評價</th>         
            <td colspan="8"><?=$open['comment']?$open['fulfil_volume']:'-';?></td>
            <td></td><td></td>
     </tr>   
        <!--
         <th>建立人</th>        
         <th>建立時間 </th>
         <th>修改人 </th>
         <th>修改時間 </th> 
         -->   
         <tr></tr>	              
         <tr><th colspan="16"><br><br>當前持有</th></tr> 
         <tr>
         <th>客戶編號</th>
         <td colspan="8"><?=$userasset['user_id']?$userasset['user_id']:"-";?></td>         
         <th>商品編號</th>
         <td colspan="8"><?=$userasset['asset_id']?$userasset['asset_id']:"-";?></td>
         </tr>
         <tr>
         <th>手數</th>
         <td colspan="8"><?=$userasset['volume']?$userasset['volume']:"-";?></td>
         <th>平均價格</th>
         <td colspan="8"><?=$userasset['average_price']?$userasset['average_price']:"-";?></td> 
         </tr>
         <tr>
         <th>狀態 </th>
         <td colspan="8"><?=$userasset['status']?$userasset['status']:"-";?></td>
         <td></td><td></td>
        </tr>
</table>

</div>