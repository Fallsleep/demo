<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="common/inc.jsp"%>   
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
	<link href="css/entity.css" rel="stylesheet" type="text/css"/>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript">
		$(function(){
			$(".avatar_div").hover(function(){
				$(".change_btn_div").css({"display" : "block"});
			},function(){
				$(".change_btn_div").css({"display" : "none"});
			});
		});
	</script>
	<style type="text/css">
	<!--
	body {
		margin-left: 0px;
		margin-top: 0px;
		margin-right: 0px;
		margin-bottom: 0px;
		font-size: 12px;
	}
	.notice{
		font-size: 12px;
		color: red;
	}
	input[type="password"],input[type="text"]{
		width: 150px;
	}
	input[required="required"] + span:before{
		content: "*";
		font-family: serif;
	}
	#tooltip{
		width: 120px;
		color: black;
		display: none;
		padding: 5px;
		border: 1px solid black;
		background-color: #FFFFCC;
	}
	.avatar_div{
		width: 180px;
		height: 180px;
		float: right;
		border: 1px solid black;
		position: relative;background-color: #333333;
	}
	.change_btn_div{
		width: 60px;
		height: 18px;
		bottom: 12px;
		right: 12px;
		position: absolute;
		text-align: center;
		background-color: #F2F2F2;
		display: none;
		border: 1px solid white;
	}
	.change_btn_div:hover{
		background-color: white;
	}
	a:link, a:visited, a:hover{
		color: black;
		text-decoration: none;
	}
	a span{
		padding: 2px;
	}
	-->
	</style>
</head>
<body>
	<div id="formwrapper">
		<form action="system/user.action" method="post" onsubmit="return check();">
			<input type="hidden" name="method:userInfoInput"/>
			<fieldset>
				<legend>
					用户信息
				</legend>
				<div class="avatar_div">
					<img src="${login.avatar }"/><br />
					<div class="change_btn_div">
						<a href="system/user!avatarInput.action">
							<span>更换头像</span>
						</a>
					</div>
				</div>
				<div>
					<label for="id">ID</label>
					<input type="text" name="id" id="id" value="${login.id }" disabled="disabled"/><br />
				</div>
				<div>
					<label for="username">用户名</label>
					<input type="text" name="username" id="username" value="${login.username }" disabled="disabled"/><br />
				</div>
				<div>
					<label for="name">姓名</label>
					<input type="text" name="name" id="name" value="${login.name }"
						required="required" maxlength="16"/><span class="notice"></span><br />
				</div>
				<div>
					<label for="username">角色</label>
					<select name="roles" multiple="multiple" disabled="disabled">
						<s:iterator value="#roles">
						<option value="<s:property value='id'/>" selected="selected"><s:property value="name"/></option>
						</s:iterator>
					</select>
					<br />
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

