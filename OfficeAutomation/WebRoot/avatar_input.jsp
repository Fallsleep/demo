<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<base href="<%=basePath%>">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>用户信息</title>
	<link href="js/avatar/themes/avatar.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.core.min.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.theme.min.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.button.min.css" rel="stylesheet" type="text/css"/>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.core.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.widget.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.button.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.mouse.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.draggable.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.position.min.js"></script>
	<script type="text/javascript" src="js/avatar/avatar1.js"></script>
	<script type="text/javascript">
	$(function(){
		$("#formwrapper").avatar({
			"ajax": {
				"url" : "system/user!uploadAvatar.action"
			}
		});
	});
	</script>
</head>
<body>
	<div id="formwrapper"></div>
</body>
</html>

