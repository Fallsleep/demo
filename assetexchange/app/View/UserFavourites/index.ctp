<!-- File: /app/View/UserFavourites/index.ctp -->

<?php // header("Refresh: 10; URL=" . $_SERVER['REQUEST_URI']); ?>

<script>
$(document).ready(function() {
    $('.rise .sign').text('+');
});
</script>

<style>
.right { text-align: right; }
.rise { color: green; }
.fall { color: red; }
col { border-right: 1px solid #ddd; }
col:last-child { border-right: 0; }
#UserFavouriteIndexForm label { display: inline; margin-right: 5px;}
#UserFavouriteIndexForm input[type=text] { padding: 3px; margin-right: 5px; width: 100px; }
</style>

<div class="form-header">喜愛的物業 - <?=date('n月j日 H:i')?></div>
<div class="form-content">
	<?php 
	echo $this->Form->create('UserFavourite', array('url' => '/UserFavourites/add'));
	echo $this->Form->input('symbol', array('label' => '商品編號', 'type' => 'text', 'div' => false));
	echo $this->Form->end(array('label' => '新增', 'div' => false)); 
	?>
	<table>
		<col><col><col><col><col><col><col><col><col><col><col><col><col>
		<tr><th>代號</th><th>股價</th><th colspan="2">升趺及升跌幅%</th><th colspan="2">是日最低價及最高價</th>
			<th>成交量</th><th>持有股數</th><th>可動用股數</th><th>平均買入價</th><th colspan="2"></th></tr>
		<?php foreach ($favs as $fav) { ?>
		<tr>
			<td><?=$this->Html->link($fav['Asset']['symbol'], '/assets/view/' . $fav['Asset']['id'])?></td>
			<td class="right"><b><?=number_format($fav['last'],3)?></b></td>
			<td class="right<?php if ($fav['change']) { echo ($fav['change']>0)?' rise':' fall'; } ?>"><b><?=$fav['change']?></b></td>
			<td class="right<?php if ($fav['change']) { echo ($fav['change']>0)?' rise':' fall'; } ?>"><b><span class="sign"></span><?=number_format($fav['change_per'], 2); ?>%</b></td>
			<td class="right"><?=number_format($fav['day_low'],3)?></td>
			<td class="right"><?=number_format($fav['day_high'],3)?></td>
			<td class="right"><?=$fav['volume']?></td>
			<td class="right"><?=$fav['user_volume']?></td>
			<td class="right"><?=$fav['avail_volume']?></td>
			<td class="right"><?=isset($fav['average_price'])?number_format($fav['average_price'], 3):'-'?></td>
			<td>
				<div class="buy_price"><?=$fav['closest_price']['B']?number_format($fav['closest_price']['B'], 2):'-'?></div>
				<?=$this->Html->link('買賣', '/opens/trade/' . $fav['Asset']['id'])?>
				<div class="sell_price"><?=$fav['closest_price']['S']?number_format($fav['closest_price']['S'], 2):'-'?></div>
			</td>
			<td><?=$this->Form->postlink('<span class="icon">Â</span>', '/UserFavourites/delete/' . $fav['UserFavourite']['id'], array('escape' => false))?></td>
		</tr>
		<?php } ?>
	</table>
</div>