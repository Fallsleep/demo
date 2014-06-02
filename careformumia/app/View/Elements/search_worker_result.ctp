<!-- File: /app/View/Elements/search_result.ctp -->

<table>
    <tr>
        <th>陪月員編號</th>
        <th>中文姓名</th>
        <th>英文名字</th>
        <th>英文姓氏</th>
        <th>手提電話</th>
        <th>其他電話</th>
        <th>地址</th>
        <th>出生日期</th>
        <th>婚姻狀況</th>
        <th>評語</th>
        <!--th>戶口銀行</th>
        <th>戶口號碼</th>
        <th>廣東話</th>
        <th>普通話</th>
        <th>英語</th>
        <th>日語</th>
        <th>接受雙胞胎?</th>
        <th>接受8小時?</th>
        <th>8小時薪金</th>
        <th>接受10小時?</th>
        <th>10小時薪金</th>
        <th>接受12小時?</th>
        <th>12小時薪金</th>
        <th>接受24小時?</th>
        <th>24小時薪金</th>
        <th>年資</th>
        <th>狀況</th>
        <th>建立時間</th>
        <th>建立人</th>
        <th>修改時間</th>
        <th>修改人</th-->        
    </tr>

    <!-- Here is where we loop through our $workers array, printing out worker info -->

    <?php 
	if (empty($workers_result))
		echo('沒有相關檢索結果！');

	foreach ($workers_result as $worker): 
		switch($worker['Worker']['mariage_status']){
			case "S": $marital_status = "單身"; break;
			case "M": $marital_status = "已婚"; break;
			case "D": $marital_status = "離婚"; break;
			case "W": $marital_status = "喪偶"; break;
		}
		$languages = array("cantonese","mandarin","english","japanese");
		foreach($languages as $language){
			switch($worker['Worker'][$language]){
				case 0: $$language = "不懂"; break;
				case 1: $$language = "一般"; break;
				case 2: $$language = "流利"; break;
			}
		}
		switch($worker['Worker']['status']){
			case "A": $status = "活躍"; break;
			case "IA": $status = "不活躍"; break;
		}
	?>
    <tr>
        <td><?php echo $this->Html->link($worker['Worker']['worker_no'], array('action' => 'view', $worker['Worker']['id'])); ?></td>
        <td><?php echo $worker['Worker']['chi_name']; ?></td>
        <td><?php echo $worker['Worker']['eng_first_name']?$worker['Worker']['eng_first_name']:"-"; ?></td>
        <td><?php echo $worker['Worker']['eng_last_name']?$worker['Worker']['eng_last_name']:"-"; ?></td>
        <td><?php echo $worker['Worker']['mobile']; ?></td>
        <td><?php echo $worker['Worker']['contact_other']?$worker['Worker']['contact_other']:"-"; ?></td>
        <td><?php echo $worker['Worker']['address']?$worker['Worker']['address']:"-"; ?></td>
        <td><?php echo $worker['Worker']['date_of_birth']?$worker['Worker']['date_of_birth']:"-"; ?></td>
        <td><?php echo $marital_status; ?></td>
        <td><?php echo $worker['Worker']['comments']?$worker['Worker']['comments']:"-"; ?></td>
        <!--td><?php echo $worker['Worker']['bank_name']?$worker['Worker']['bank_name']:"-"; ?></td>
        <td><?php echo $worker['Worker']['bank_account']?$worker['Worker']['bank_account']:"-"; ?></td>
		<?php foreach($languages as $language){ ?>
		<td><?php echo $$language; ?></td>
		<?php } ?>
        <td><?php echo $worker['Worker']['accept_twins']?"是":"否"; ?></td>
        <td><?php echo $worker['Worker']['accept8']?"是":"否"; ?></td>
        <td><?php echo $worker['Worker']['wage8']?$worker['Worker']['wage8']:"-"; ?></td>
        <td><?php echo $worker['Worker']['accept10']?"是":"否"; ?></td>
        <td><?php echo $worker['Worker']['wage10']?$worker['Worker']['wage10']:"-"; ?></td>
        <td><?php echo $worker['Worker']['accept12']?"是":"否"; ?></td>
        <td><?php echo $worker['Worker']['wage12']?$worker['Worker']['wage12']:"-"; ?></td>
        <td><?php echo $worker['Worker']['accept24']?"是":"否"; ?></td>
        <td><?php echo $worker['Worker']['wage24']?$worker['Worker']['wage24']:"-"; ?></td>
        <td><?php echo number_format($worker['Worker']['year_exp'],1); ?></td>
        <td><?php echo $status; ?></td>
        <td><?php echo $worker['Worker']['created']; ?></td>
        <td><?php echo $worker['Worker']['created_by']; ?></td>
        <td><?php echo $worker['Worker']['modified']=="0000-00-00 00:00:00"?"-":$worker['Worker']['modified']; ?></td>
        <td><?php echo $worker['Worker']['modified_by']?$worker['Worker']['modified_by']:"-"; ?></td-->
	</tr>
    <?php endforeach; ?>
</table>