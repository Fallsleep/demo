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
	<title>更新角色</title>
<link href="css/entity.css" rel="stylesheet" type="text/css"/>
</head>
<body>

<div id="formwrapper">
	<h3>设置角色的信息</h3>
	<form action="system/role.action" method="post">
	<input type="hidden" name="method:update">
	<input type="hidden" name="id" value="<s:property value="id"/>">
	<fieldset>
		<legend>角色基本信息
		</legend>
		<div>
			<label for="name">角色名</label>
			<input type="text" name="name" id="name" value="${name }" size="60"  /> 
			<br />	
		</div>
		<div class="enter">
		    <input name="submit" type="submit" class="buttom" value="保存角色" />
		    <input name="reset" type="reset" class="buttom" value="重置" />
		</div>		
	</fieldset>
	</form>
</div>

</body>
</html>

