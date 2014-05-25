<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/common/inc.jsp"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<html>
<head>
<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>角色管理页面</title>
<link href="css/entity.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<style type="text/css" title="currentStyle">
@import "js/datatable/css/demo_page.css";
@import "js/datatable/css/demo_table.css";
</style>
<script type="text/javascript">
	var oTable;
	$(function(){
		var buttons = "<input type='button' value='添加角色' onclick='addRole()'/>" +
			"<input type='button' value='更新角色' onclick='updateRole()'/>" +
			"<input type='button' value='删除角色' onclick='deleteRole()'/>";
		oTable = $("#roleList").dataTable({
			"bProcessing":true,
			"bServerSide":true,
			"bStateSave":true,
			"sAjaxSource":"system/role!list.action",
			"sPaginationType":"full_numbers",
			"oLanguage":{
				"sProcessing":"Processing...",
				"sLengthMenu":"Display _MENU_ records" + buttons,
				"sEmptyTable":"No data available in table",
				"sZeroRecords":"No data available in table",
				"sInfo": "Showing _START_ to _END_ of _TOTAL_ entries",
				"sInfoEmpty": "No entries to show",
				"sSearch": "Search:",
				"oPaginate" : {
					"sFirst" : "First",
					"sLast" : "Last",
					"sNext" : "Next",
					"sPrevious" : "Previous"
				}
			}
		});
		//点击时选中表行
		$("#roleList tbody").click(
			function(event){
				/*
				$(oTable.fnSettings().aoData).each(
					function(){
						$(this.nTr).removeClass("row_selected");
					}
				);
				*/
				var ons = oTable.fnGetNodes();
				for(var i = 0; i < ons.length; ++i){
					$(ons[i]).removeClass("row_selected");
				}
				$(event.target.parentNode).addClass("row_selected");
			}
		);
		oTable.css("font-size", "12px");
	});
	
	function addRole(){
		window.location = "system/role!addInput.action";
	}
	
	function updateRole(){
		var anSelected = fnGetSelected(oTable);
		if(anSelected.length == 0){
			alert("请选中要更新的角色!");
			return ;
		}
		//获取选中人员的ID
		var roleId = anSelected[0].children[0].innerHTML;
		window.location = "system/role!updateInput.action?id=" + roleId;
	}
	
	function deleteRole(){
		var anSelected = fnGetSelected(oTable);
		if(anSelected.length == 0){
			alert("请选中要删除账号的人员!");
			return ;
		}
		if(confirm("删除不可恢复，是否确定要删除角色[" + anSelected[0].children[1].innerHTML + "]?")){
			//获取选中人员的ID
			var roleId = anSelected[0].children[0].innerHTML;
			$.get("system/role!del.action?id=" + roleId, function(){
				oTable.fnDeleteRow(anSelected[0]);
			});
		}
	}
	//获得选中行集合的方法
	function fnGetSelected(oTab){
		var aReturn = new Array();
		var aTrs = oTab.fnGetNodes();
		for(var i = 0; i < aTrs.length; ++i){
			if($(aTrs[i]).hasClass("row_selected")){
				aReturn.push(aTrs[i]);
			}
		}
		return aReturn;
	}
</script>
</head>
<body>
	<table cellpadding="0" cellspacing="0" border="0" class="display"
		id="roleList" width="100%">
		<thead>
			<tr>
				<th>ID</th>
				<th>角色名</th>
			</tr>
		</thead>
		<tbody>
			<tr class="odd gradeX">
				<td colspan="2">目前暂时没有内容！</td>
			</tr>
		</tbody>
	</table>
</body>
</html>

