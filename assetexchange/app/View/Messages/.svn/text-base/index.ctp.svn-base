<!-- File: /app/View/Messages/index.ctp -->
<?php echo $this->element('submenu', array('sub' => 'ah')); ?>
<br><br>

<table>
	<thead><th width="150">發出日期</th><th>標題</th></thead>
	<?php foreach ($msgs as $msg) { ?>
	<tr>
		<td width="150"><?php echo $msg['Message']['created'];?></td>
		<td><a href="#" onclick="news_show(<?php echo $msg['Message']['id'] ?>)" class="<?php echo ($msg['Message']['status'] == 'R')? 'read_message':'unread_message';?>"><?php echo $msg['Message']['subject'];?></a></td>
	</tr>
	<?php } ?>
</table>

<div id="message_detail"></div>

<script type="text/javascript">

$(document).ready(function() {
	
	$("#message_detail").dialog({
		autoOpen:false,
		modal: true,
		width: 600,
		show: {
			effect: "explode",
			duration: 100
		},
		hide: {
			effect: "blind",
			duration: 100
		},
    	position: ['center',40]
	});

});

function news_show(id) {
	//$("#message_detail").dialog('option', 'title', 'Edit Event');
	$("#message_detail").empty();
	$("#message_detail").load('<?php echo Router::url(array(
							    'controller' => 'messages',
							    'action' => 'view'
							    ))
							    ?>' + '/' + id);
	//$("#news_data_frame").attr("src", url);
	$("#message_detail").dialog("open");
}



</script>