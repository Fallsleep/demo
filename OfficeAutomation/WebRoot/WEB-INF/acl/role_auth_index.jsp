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
	<title>角色授权主界面</title>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.jstree.js"></script>
<script language="javascript">
	$(function(){
		//将menuContainer变成一棵树！
		$("#roleTree").jstree({
			"json_data" : {
				"ajax" : {
					"url" : "system/acl!roleAuthIndexTree.action"
				}
			},
			"themes" : {
				"theme" : "classic"
			},
			"plugins" : ["themes","json_data", "ui"]
		});
		$("#roleTree").bind(
			"loaded.jstree",
			function(event){
				$("#roleTree").jstree("open_all", -1);
			}
		);
		$("#roleTree").bind(
			"select_node.jstree",
			function(event, data){
				var principalId = data.rslt.obj.attr("id");
				var principalType = data.rslt.obj.attr("principalType");
				$("#rightFrame").attr("src", "system/acl!allMenuResource.action?principalId=" + principalId + "&principalType=" + principalType);
			}
		);
		$("#roleTree").css("font-size", "12px");
	});
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

-->
</style>
</head>
<body>
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="150" valign="top"><div id="roleTree"></div></td>
	<td width="8" bgcolor="#add2da">&nbsp;</td>
	<td>
		<iframe src="right.jsp" width="100%" height="100%" frameborder="0" id="rightFrame"></iframe>
	</td>
	<td width="8" bgcolor="#add2da">&nbsp;</td>
</tr>
</table>
</body>
</html>

