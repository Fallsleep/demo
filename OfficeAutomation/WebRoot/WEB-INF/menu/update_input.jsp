<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/common/inc.jsp"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<html>
<head>
<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>更新菜单信息</title>
<link href="css/entity.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<style type="text/css" title="currentStyle">
@import "js/datatable/css/demo_page.css";

@import "js/datatable/css/demo_table.css";
</style>
</head>
<body>
	<div id="formwrapper">
		<h3>更新菜单的基本信息</h3>
		<form action="system/menu.action" method="post">
			<input type="hidden" name="method:update"> 
			<input type="hidden" name="id" value="<s:property value="id"/>">
			<input type="hidden" name="parent.id" value="<s:property value="parent.id"/>">
			<fieldset>
				<legend>
					菜单基本信息
					<input type="button" value="添加下级菜单" 
						onclick="window.location = 'system/menu!addInput.action?parent.id=${id}'"/>
					<input type="button" value="删除当前菜单" 
						onclick="window.location = 'system/menu!del.action?id=${id}'"/>
				</legend>
				<div>
					<label for="name">名称</label>
					 <input type="text" name="name"	id="name" value="${name }" size="60" /> <br />
				</div>
				<div>
					<label for="href">链接地址</label>
					<input type="text" name="href" id="href" value="${href }" size="30" /> <br />
				</div>
				<div>
					<label for="orderNumber">排序号</label>
					<input type="text" name="orderNumber" id="orderNumber" value="${orderNumber }" size="30" /> <br />
				</div>
				<div>
					<label for="sn">编号</label>
					<input type="text" name="sn" id="sn" value="${sn }" size="60" /> <br />
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

