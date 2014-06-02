<!-- File: /app/View/Elements/search_job_result.ctp -->

<table>
    <tr>
    	<th>申請編號</th>
        <th>客戶編號</th>
        <th>中文姓名</th>
        <th>英文姓名</th>
        <th>手提電話</th>
        <th>其他電話</th>
        <th>地區</th>
        <th>地址</th>
        <th>年齡</th>
        <th>分娩方式</th>
        <th>哺育方式</th>
        <th>生產醫院</th>
        <th>預產日期</th>
        <th>生產日期</th>
        <!--th>有幾個小孩？</th>
        <th>是否有傭人？</th>
        <th>是否有寵物？</th>
        <th>工作天數</th>
        <th>前後延長天數</th>
        <th>工作時數</th>
        <th>提供月薪</th>
        <th>陪月員年資</th>
        <th>陪月員年齡</th>
        <th>提供月薪</th>
        <th>廣東話</th>
        <th>普通話</th>
        <th>英語</th>
        <th>日語</th>
        <th>開工日期</th>
        <th>結束日期</th>
        <th>狀況</th>
        <th>備註</th>
        <th>建立時間</th>
        <th>建立人</th>
        <th>修改時間</th>
        <th>修改人</th-->        
    </tr>

    <!-- Here is where we loop through our $jobs array, printing out worker info -->

    <?php
    
    if (empty($jobs_result))
		echo('沒有相關檢索結果！');
    
     
	foreach ($jobs_result as $job): 
		switch($job['Job']['birth_method']){
			case "N": $birth_method = "自然分娩"; break;
			case "P": $birth_method = "剖腹分娩"; break;
			case "T": $birth_method = "无痛分娩"; break;
			case "W": $birth_method = "水中分娩"; break;
			default: $birth_method = "-"; 
		}
		switch($job['Job']['milk_type']){
			case "0": $milk_type = "母乳餵養"; break;
			case "1": $milk_type = "奶粉餵養"; break;
			case "2": $milk_type = "母乳與奶粉混合"; break;
			default: $milk_type = "-";
		}
		switch($job['Job']['wage']){
			case "10000": $wage = "$10000或以下"; break;
			case "10001": $wage = "$10001-12000"; break;
			case "12001": $wage = "$12001-14000"; break;
			case "14001": $wage = "$14001-16000"; break;
			case "16001": $wage = "$16000以上"; break;
			default: $wage = "-";
		}
		switch($job['Job']['year_exp']){
			case "0": $year_exp = "不限"; break;
			case "2": $year_exp = "2年或以上"; break;
			case "5": $year_exp = "5年或以上"; break;
			case "7": $year_exp = "7年或以上"; break;
			case "10": $year_exp = "10年或以上"; break;
			default: $year_exp = "-";
		}
		switch($job['Job']['age']){
			case "0": $age = "不限"; break;
			case "30": $age = "30歲或以下"; break;
			case "31": $age = "31-40歲"; break;
			case "41": $age = "41-50歲"; break;
			case "51": $age = "50歲以上"; break;
			default: $age = "-";
		}
		$languages = array("cantonese","mandarin","english","japanese");
		foreach($languages as $language){
			switch($job['Job'][$language]){
				case 0: $$language = "不限"; break;
				case 1: $$language = "一般"; break;
				case 2: $$language = "流利"; break;
				default: $$language = "-";
			}
		}
		switch($job['Job']['status']){
			case "P": $status = "待配對"; break;
			case "M": $status = "已配對"; break;
			default: $status = "-";
		}
	?>
    <tr>
        <td><?php echo $this->Html->link($job['Job']['id'], array('action' => 'view', $job['Job']['id'])); ?></td>
        <td><?php echo $job['Job']['customer_id']; ?></td>
        <td><?php echo $job['Job']['mother_chi_name']; ?></td>
        <td><?php echo $job['Job']['mother_eng_name']; ?></td>
        <td><?php echo $job['Job']['mother_mobile']; ?></td>
        <td><?php echo $job['Job']['mother_contact']; ?></td>
        <td><?php echo $job['District']['district_name']; ?></td>
        <td><?php echo $job['Job']['work_address']; ?></td>
        <td><?php echo $job['Job']['mother_age']; ?></td>
        <td><?php echo $birth_method; ?></td>
        <td><?php echo $milk_type; ?></td>
        <td><?php echo $job['Job']['hostipal']; ?></td>
        <td><?php echo $job['Job']['expected_ddate']; ?></td>
        <td><?php echo $job['Job']['delivery_date']; ?></td>
        <!--td><?php echo $job['Job']['num_of_child']; ?></td>
        <td><?php echo $job['Job']['have_servant']?"是":"否"; ?></td>
        <td><?php echo $job['Job']['have_pet']?"是":"否"; ?></td>
        <td><?php echo $job['Job']['work_days']; ?></td>
        <td><?php echo $job['Job']['extand']; ?></td>
        <td><?php echo $job['Job']['work_hours']; ?></td>
        <td><?php echo $wage; ?></td>
        <td><?php echo $year_exp; ?></td>
        <td><?php echo $age; ?></td>
        <?php foreach($languages as $language){ ?>
		<td><?php echo $$language; ?></td>
		<?php } ?>
        <td><?php echo $job['Job']['work_start']=="0000-00-00"?"-":$job['Job']['work_start']; ?></td>
        <td><?php echo $job['Job']['work_end']=="0000-00-00"?"-":$job['Job']['work_end']; ?></td>
        <td><?php echo $status; ?></td>
        <td><?php echo $job['Job']['remark']; ?></td>
        <td><?php echo $job['Job']['created']; ?></td>
        <td><?php echo $job['Job']['created_by']; ?></td>
        <td><?php echo $job['Job']['modified']=="0000-00-00 00:00:00"?"-":$job['Job']['modified']; ?></td>
        <td><?php echo $job['Job']['modified_by']; ?></td-->
    </tr>
    <?php endforeach; ?>
</table>