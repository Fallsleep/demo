<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
<base href="<%=basePath%>">
<title>领航办公自动化(OA)系统</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style type="text/css">
.textfield {
	margin: 0px;
	height: 21px;
	width: 106px;
	border: 1px solid #000;
}
#form{
    position:absolute;
	margin:389px 430px;
}
#password{
	position:relative;
	margin:-22px 170px;
}
#submit{
	position:relative;
	margin:-22px 340px;
}
.word{
	font-size:12px;
	font-family:"宋体";
}
.tip{
	font-size:12px;
	color:red;
	font:"serif";
}
</style>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript">
	function ajax(){
		var username = $("#username input").val();
		var password = $("#password input").val();
		var param = "username=" + username + "&password=" + password + "&_rnd=" + Math.random()*1E16;
		$.post("system/login.action",param,function(data, textStatus){
			if(data == null){
				window.location.replace("system/index.action");
			}else if(data.error == 1){
				alert("用户["+ username +"]不存在");
				return;
			}else if(data.error == 2){
				alert("密码错误");
				return;
			}
		}, "json");
		return false;
	}
</script>
</head>
<body background="images/index.jpg" bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<div id="form">
<form method="post" action="system/login.action" onsubmit="return ajax();">
	<div id="username" class="word">用户：<input style="border:solid #000000 1px; width:120px; height:20" name="username" type="text"/></div>
	<div id="password" class="word">密码：<input style="border:solid #000000 1px; width:120px; height:20" name="password" type="password"/></div>
	<div id="submit"><input type="image" src="images/submit.jpg"/></div><br/><br/>
	<div class="tip">管理员用户：admin	初始密码：admin</div>
</form>
</div>
</body>
</html>