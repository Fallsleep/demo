<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/common/inc.jsp" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>添加人员账号</title>
<link href="css/entity.css" rel="stylesheet" type="text/css"/>
</head>
<body>

<div id="formwrapper">
	<h3>设置人员的登录账号</h3>
	<form action="system/user.action" method="post">
	<input type="hidden" name="method:add">
	<input type="hidden" name="person.id" value="<s:property value="person.id"/>">
	<fieldset>
		<legend>账号基本信息
		</legend>
		<div>
			<label for="username">登录账号</label>
			<input type="text" name="username" id="username" value="${username }" size="60"  /> 
			<br />	
		</div>
		<div>
			<label for="password">密码</label>
			<input type="text" name="password" id="password" value="${password }" size="30"  /> 
			<br />	
		</div>
		<div>
			<label for="roles">分配角色</label>
			<select name="roleIds" multiple="multiple">
				<s:iterator value="roles">
					<option value="<s:property value="id"/>"><s:property value="name"/></option>
				</s:iterator>
			</select>
			<br />	
		</div>
		<div class="enter">
		    <input name="submit" type="submit" class="buttom" value="保存登录账号" />
		    <input name="reset" type="reset" class="buttom" value="重置" />
		</div>		
	</fieldset>
	</form>
</div>

</body>
</html>

