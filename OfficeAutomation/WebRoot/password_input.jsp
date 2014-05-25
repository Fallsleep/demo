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
	<title>修改密码</title>
	<link href="css/entity.css" rel="stylesheet" type="text/css"/>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript">
		$(function(){
			$("input[type='password']").keyup(function(e){
				var len = e.target.value.length;
				$(e.target).next().text(len + "/" + e.target.maxLength);
			}).focus(function(e){//mouseover
				$(e.target).next().text("");
				var x = e.target.offsetLeft + e.target.offsetWidth + 100;
				var y = e.target.offsetTop;
				var myTitle = "以字母、数字、下划线开头，6~16个字符，区分大小写，不能含有空格";
				var tooltipHtml = "<div id='tooltip'>" + myTitle + "</div>"; //创建提示框
				$("body").append(tooltipHtml); //添加到页面中
				$("#tooltip").css({
					"top": y + "px",
					"left": x + "px",
					"position":"absolute",
					"display":"block"
				}).show("fast");//设置提示框的坐标，并显示
			}).blur(function(e){
				$(e.target).next().text("");
				$("#tooltip").remove();
				check();
			});
		});
		function check(){
			var oldPassword = $("#oldPassword").val();
			var newPassword = $("#newPassword").val();
			var passwordAgain = $("#passwordAgain").val();
			//是否含有空格
			var pattSpace = new RegExp(" ");
			//是否为空
			if((oldPassword == null || oldPassword == "") && $("#oldPassword + span").text() == ""){
				$("#oldPassword + span").text("不能为空！");
				return false;
			}
			if(pattSpace.test(oldPassword) && $("#oldPassword + span").text() == ""){
				$("#oldPassword + span").text("不能含有空格！");
				return false;
			}
			if((newPassword == null || newPassword == "" && $("#newPassword + span").text() == "")){
				$("#newPassword + span").text("不能为空！");
				return false;
			}
			if(pattSpace.test(newPassword) && $("#newPassword + span").text() == ""){
				$("#newPassword + span").text("不能含有空格！");
				return false;
			}
			if((passwordAgain == null || passwordAgain == "") && $("#passwordAgain + span").text() == ""){
				$("#passwordAgain + span").text("不能为空！");
				return false;
			}
			if(pattSpace.test(passwordAgain) && $("#passwordAgain + span").text() == ""){
				$("#passwordAgain + span").text("不能含有空格！");
				return false;
			}
			//两次密码是否一致
			if(newPassword != passwordAgain){
				if($("#passwordAgain + span").text() == ""){
					$("#passwordAgain + span").text("两次密码不一致！");
				}
				return false;
			}
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
	.notice{
		font-size:12px;
		color:red;
	}
	#formwrapper { 
		margin: 80px auto;
		padding: 20px;
		text-align: left;
		width: 40%;
	}
	fieldset{
		padding: 40px 10px;
	}
	fieldset label{
		width:90px;
	}
	input[type="password"]{
		width:150px;
	}
	input[required="required"] + span:before{
		content:"*";
		font-family: serif;
	}
	#tooltip{
		width:120px;
		color:black;
		display:none;
		padding:5px;
		text-align:left;
		border:1px solid black;
		background-color:#FFFFCC;
	}
	-->
	</style>
</head>
<body>
	<div id="formwrapper">
		<form action="system/user.action" method="post" onsubmit="return check();">
			<input type="hidden" name="method:changePassword"/>
			<fieldset>
				<legend>
					修改密码
				</legend>
				<div>
					<label for="oldPassword">旧密码</label>
					<input type="password" name="oldPassword" id="oldPassword"
						required="required" maxlength="16"/><span class="notice"></span><br />
				</div>
				<div>
					<label for="password">新密码</label>
					<input type="password" name="newPassword" id="newPassword"
						required="required" maxlength="16"/><span class="notice"></span><br />
				</div>
				<div>
					<label for="passwordAgain">重复新密码</label>
					<input type="password" name="passwordAgain" id="passwordAgain"
						required="required" maxlength="16"/><span class="notice"></span><br />
				</div>
				<div class="enter">
					<input name="submit" type="submit" class="buttom" value="提交" autofocus="autofocus" />
					<input name="reset" type="reset" class="buttom" value="重置" />
				</div>
			</fieldset>
		</form>
	</div>
</body>
</html>

