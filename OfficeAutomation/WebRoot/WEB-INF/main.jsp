<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<base href="<%=basePath%>">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>欢迎使用领航办公自动化(OA)平台</title>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript">
	$(function(){
		$(window).bind("beforeunload", function (event){
			var message = "将要离开页面，是否要";
			event.returnValue = message;
			return message;
		});
		$(window).bind("unload", function (event){
			$.get("system/login!quit.action");
		});
	});
	</script>
</head>
<frameset rows="80,*,11" frameborder="no" border="0" framespacing="0">
	<frame src="top.jsp" name="topFrame" scrolling="No"
		noresize="noresize" id="topFrame" />
	<frame src="system/index!center.action" name="mainFrame" id="mainFrame" />
	<frame src="down.jsp" name="bottomFrame" scrolling="No"
		noresize="noresize" id="bottomFrame" />
</frameset>
<noframes>
<body>
</body>
</noframes>
</html>

