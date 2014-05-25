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
<title>添加或更新公司信息</title>
<link href="css/entity.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<style type="text/css" title="currentStyle">
@import "js/datatable/css/demo_page.css";

@import "js/datatable/css/demo_table.css";
</style>
<script type="text/javascript">
	var parentId = <s:property value='id'/>;
</script>
<script type="text/javascript" src="js/org/theme/person_tab.js"></script>
</head>
<body>
	<div id="formwrapper">
		<h3>更新公司的基本信息</h3>
		<form action="system/company.action" method="post">
			<input type="hidden" name="method:update"> 
			<input type="hidden" name="id" value="<s:property value="id"/>">
			<input type="hidden" name="parent.id" value="<s:property value="parent.id"/>">
			<fieldset>
				<legend>
					公司基本信息
					<s:if test="permit('department','CREATE')">
					<input type="button" value="添加下级部门" 
							onclick="window.location = 'system/department!addInput.action?parent.id=${id}'"/>
					</s:if>
					<s:if test="permit('company','CREATE')">
					<input type="button" value="添加子公司" 
						onclick="window.location = 'system/company!addInput.action?parent.id=${id}'"/>
					</s:if>
					<s:if test="permit('company','DELETE')">
					<input type="button" value="删除公司信息" 
						onclick="window.location = 'system/company!del.action?id=${id}'"/>
					</s:if>
				</legend>
				<div>
					<label for="name">名称</label>
					<input type="text" name="name" id="name" value="${name }" size="60" /> <br />
				</div>
				<div>
					<label for="tel">电话</label>
					<input type="text" name="tel" id="tel" value="${tel }" size="30" /> <br />
				</div>
				<div>
					<label for="fax">传真</label>
					<input type="text" name="fax" id="fax" value="${fax }" size="30" /> <br />
				</div>
				<div>
					<label for="address">地址</label>
					<input type="text" name="address" id="address" value="${address }" size="60" /> <br />
				</div>
				<div>
					<label for="postcode">邮编</label>
					<input type="text" name="postcode" id="postcode" value="${postcode }" size="20" /> <br />
				</div>
				<div>
					<label for="site">网站</label>
					<input type="text" name="site" id="site" value="${site }" size="30" /> <br />
				</div>
				<div>
					<label for="email">电子邮件</label>
					<input type="text" name="email" id="email" value="${email }" size="30" /> <br />
				</div>
				<div>
					<label for="industry">所属行业</label>
					<input type="text" name="industry" id="industry" value="${industry }" size="30" />
					<br />
				</div>
				<div>
					<label for="description">描述</label>
					<input type="text" name="description" id="description" value="${description }" size="60" /> <br />
				</div>
				<div class="enter">
					<input name="submit" type="submit" class="buttom" value="提交" />
					<input name="reset" type="reset" class="buttom" value="重置" />
				</div>
			</fieldset>
		</form>
	</div>
	<table cellpadding="0" cellspacing="0" border="0" class="display"
		id="personList" width="100%">
		<thead>
			<tr>
				<th>ID</th>
				<th>姓名</th>
				<th>性别</th>
				<th>电话</th>
			</tr>
		</thead>
		<tbody>
			<tr class="odd gradeX">
				<td colspan="4">目前暂时没有内容！</td>
			</tr>
		</tbody>
	</table>
</body>
</html>

