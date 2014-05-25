<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/inc.jsp" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>用户授权主界面</title>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.jstree.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<style type="text/css" title="currentStyle">
@import "js/datatable/css/demo_page.css";

@import "js/datatable/css/demo_table.css";
</style>
<script type="text/javascript">
	var oTable;
	$(function(){
		var buttons = "<input type='button' value='添加人员' onclick='addPerson()'/>" +
			"<input type='button' value='更新人员' onclick='updatePerson()'/>" +
			"<input type='button' value='删除人员' onclick='deletePerson()'/>";
		oTable = $("#personList").dataTable({
			"bProcessing":true,
			"bServerSide":true,
			"bStateSave":true,
			"sAjaxSource":"system/acl!userAuthIndexTree.action",
			"bPaginate":false,//是否分页
			"bSort":false,//是否排序
			"bInfo":false,//是否显示信息
			"aoColumnDefs":[
				{"bVisible" : false, "aTargets" : [0]}//隐藏ID列，只显示姓名列
			],
			"oLanguage":{
				"sProcessing":"Processing...",
				"sEmptyTable":"No data available in table",
				"sZeroRecords":"No data available in table",
				"sInfoEmpty": "No entries to show",
				"sSearch": "Search:"
			}
		});
		//点击时选中表行
		$("#personList tbody").click(
			function(event){
				var ons = oTable.fnGetNodes();
				for(var i = 0; i < ons.length; ++i){
					$(ons[i]).removeClass("row_selected");
				}
				$(event.target.parentNode).addClass("row_selected");
				var principalId;
				$(oTable.fnSettings().aoData).each(
					function(){
						if($(this.nTr).hasClass("row_selected")){
							principalId = this._aData[0];
						}
					}
				);
				$("#rightFrame").attr("src", "system/acl!allMenuResource.action?principalType=User&principalId=" + principalId);
			}
		);
		oTable.css("font-size", "12px");
	});
	
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
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	font-size:12px;
}
.dataTables_filter {
	width: 100%;
	float: left;
	text-align: left;
	font-size:12px;
}
.dataTables_filter input{
	width: 66%;
	vertical-align:middle;
}
-->
</style>
</head>
<body>
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="150" valign="top">
		<table cellpadding="0" cellspacing="0" border="0" class="display"
			id="personList" width="100%">
			<thead>
				<tr>
					<th>ID</th>
					<th>选择用户授权</th>
				</tr>
			</thead>
			<tbody>
				<tr class="odd gradeX">
					<td colspan="2">目前暂时没有内容！</td>
				</tr>
			</tbody>
		</table>
	</td>
	<td width="8" bgcolor="#add2da">&nbsp;</td>
	<td>
		<iframe src="right.jsp" width="100%" height="100%" frameborder="0" id="rightFrame"></iframe>
	</td>
	<td width="8" bgcolor="#add2da">&nbsp;</td>
</tr>
</table>
</body>
</html>

