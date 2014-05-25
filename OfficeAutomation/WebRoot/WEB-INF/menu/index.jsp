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
	<title>菜单管理</title>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.jstree.js"></script>
<script language="javascript">
	$(function(){
		//计算当前页面的高度开始
		var clientHeight;
		if($.browser.msie){
			//如何是IE浏览器document.body.clientHeight属性得到窗口高度
			clientHeight = document.body.clientHeight;
		} 
		else{
			clientHeight = self.innerHeight;
		}
		//将菜单DIV高度设置成页面高度（一个绝对值，不能是百分比）
		$("#menuTree").height(clientHeight);
		//设置菜单DIV宽度
		$("#menuTree").width(150);
		//设置左右滚动条自动显示
		$("#menuTree").css("overflow", "auto");
		//计算当前页面的高度结束
		//将menuContainer变成一棵树！
		$("#menuTree").jstree({
			"json_data" : {
				"ajax" : {
					"url" : "system/menu!tree.action"
				}
			},
			"plugins" : ["themes","json_data", "ui"]
		});
		$("#menuTree").bind(
			"loaded.jstree",
			function(event){
				$("#menuTree").jstree("open_all", -1);
			}
		);
		$("#menuTree").bind(
			"select_node.jstree",
			function(event, data){
				var menuId = data.rslt.obj.attr("id");
				$("#rightFrame").attr("src", "system/menu!updateInput.action?id=" + menuId);
			}
		);
		$("#menuTree").css("font-size", "12px");
	});
	function refresh(){
		$("#menuTree").jstree("refresh", "#menuTree");
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

-->
</style>
</head>
<body>
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="150" valign="top"><div id="menuTree"></div></td>
	<td width="8" bgcolor="#add2da">&nbsp;</td>
	<td>
		<iframe src="right.jsp" width="100%" height="100%" frameborder="0" id="rightFrame"></iframe>
	</td>
	<td width="8" bgcolor="#add2da">&nbsp;</td>
</tr>
</table>
</body>
</html>

