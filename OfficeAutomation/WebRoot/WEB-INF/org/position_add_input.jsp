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
	<title>添加岗位信息</title>
<link href="css/entity.css" rel="stylesheet" type="text/css"/>
</head>
<body>

<div id="formwrapper">
	<h3>添加岗位的信息</h3>
	<form action="system/position.action" method="post">
	<input type="hidden" name="method:add">
	<input type="hidden" name="parent.id" value="<s:property value="parent.id"/>">
	<fieldset>
		<legend>岗位基本信息
		</legend>
		<div>
			<label for="name">名称</label>
			<input type="text" name="name" id="name" value="${name }" size="60"  /> 
			<br />	
		</div>
		<div>
			<label for="description">描述</label>
			<input type="text" name="description" id="description" value="${description }" size="60" /> 
			<br />	
		</div>
		<div class="enter">
		    <input name="submit" type="submit" class="buttom" value="提交" />
		    <input name="reset" type="reset" class="buttom" value="重置" />
		</div>		
	</fieldset>
	</form>
</div>

</body>
</html>

