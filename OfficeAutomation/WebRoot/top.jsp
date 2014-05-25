<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@include file="/common/inc.jsp" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CMS 后台管理工作平台</title>
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}

.STYLE1 {
	font-size: 12px;
	color: #000000;
}

.STYLE5 {
	font-size: 12
}

.STYLE7 {
	font-size: 12px;
	color: #FFFFFF;
}

.STYLE7 a {
	font-size: 12px;
	color: #FFFFFF;
}

a img {
	border: none;
}
-->
</style>
<script type="text/javascript">
	var open = true;
	function openClose() {
		if (open) {
			window.parent.mainFrame.document.getElementById("leftMenu").width = 1;
			open = false;
		} else {
			window.parent.mainFrame.document.getElementById("leftMenu").width = 147;
			open = true;
		}
	}
</script>
</head>
<body>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td background="images/main_03.gif">
				<table width="100%"	border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="100%" height="50" valign="bottom" background="images/logo_top.jpg">&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="30" align="left" background="images/main_31.gif">
				<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="8" bgcolor="#353C44">&nbsp;</td>
						<td>
							<table width="225" border="0" align="right" cellpadding="0" cellspacing="0">
								<tr>
									<td height="17">
										<div align="left">
											<a href="system/user!passwordInput.action" target="rightFrame">
											<img src="images/pass.gif" width="69" height="17" />
											</a>
										</div>
								 	</td>
									<td>
										<div align="left">
											<a href="system/user!userInfoInput.action" target="rightFrame">
											<img src="images/user.gif" width="69" height="17" />
											</a>
										</div>
									</td>
									<td>
										<div align="left">
											<a href="system/login!quit.action" target="_parent">
											<img src="images/quit.gif" alt=" " width="69" height="17" />
											</a>
										</div>
									</td>
								</tr>
							</table>
							<table width="525" border="0" align="left" cellpadding="0"
									cellspacing="0" style="font-size:12px;font-family:宋体;font-weight: bold;">
								<tr>
									<td height="17"><div align="right">当前用户:</div></td>
									<td ><div align="left">${login.name}</div></td>
									<td height="17"><div align="right">IP:</div></td>
									<td><div align="left">${login.ip}</div></td>
									<td height="17"><div align="right">登录时间:</div></td>
									<td>
										<div align="left">
											<fmt:formatDate value="${login.loginTime }" pattern="yyyy年MM月dd日 HH:mm:ss"/>
										</div>
									</td>
								</tr>
							</table>
						</td>
						<td width="8" bgcolor="#353C44">&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>

