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
<title>添加操作信息</title>
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
		<h3>操作的基本信息</h3>
		<form action="system/resource.action" method="post">
			<input type="hidden" name="method:addOper"> 
			<input type="hidden" name="id" value="<s:property value="id"/>">
			<fieldset>
				<legend>
					操作基本信息
				</legend>
				<div>
					<label for="operName">操作名称</label>
					 <input type="text" name="operName"	id="operName" value="${operName }" size="60" /> <br />
				</div>
				<div>
					<label for="operSn">操作标识</label>
					<input type="text" name="operSn" id="operSn" value="${operSn }" size="30" /> <br />
				</div>
				<div>
					<label for="methodName">方法名</label>
					<input type="text" name="methodName" id="methodName" value="${methodName }" size="30" /> <br />
				</div>
				<div>
					<label for="operIndex">操作索引</label>
					<input type="text" name="operIndex" id="operIndex" value="${operIndex }" size="30" /> <br />
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

