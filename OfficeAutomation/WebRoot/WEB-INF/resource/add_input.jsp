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
<title>添加资源信息</title>
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
		<h3>资源的基本信息</h3>
		<form action="system/resource.action" method="post">
			<input type="hidden" name="method:add">
			<s:if test="parent != null">
				<input type="hidden" name="parent.id" value="<s:property value="parent.id"/>">
				<input type="hidden" name="parentSn" value="<s:property value="parent.sn"/>">
			</s:if>
			<fieldset>
				<legend>
					资源基本信息
				</legend>
				<div>
					<label for="name">资源名称</label>
					 <input type="text" name="name"	id="name" value="${name }" size="60" /> <br />
				</div>
				<div>
					<label for="sn">唯一标识</label>
					<input type="text" name="sn" id="sn" value="${sn }" size="60" /> <br />
				</div>
				<div>
					<label for="className">类名</label>
					<input type="text" name="className" id="className" value="${className }" size="30" /> <br />
				</div>
				<div>
					<label for="orderNumber">排序号</label>
					<input type="text" name="orderNumber" id="orderNumber" value="${orderNumber }" size="30" /> <br />
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

