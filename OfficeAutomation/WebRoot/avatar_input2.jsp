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
	<title>用户信息</title>
	<link href="js/avatar/themes/avatar.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.core.min.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.theme.min.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.button.min.css" rel="stylesheet" type="text/css"/>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.core.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.widget.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.button.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.mouse.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.draggable.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.position.min.js"></script>
	<script type="text/javascript" src="js/avatar/avatar.js"></script>
</head>
<body>
	<div id="formwrapper">
		<fieldset>
			<legend>
				上传头像
			</legend>
			<form id="uploadForm" action="system/login.action" method="post" enctype="multipart/form-data">
				<input type="hidden" name="method:uploadAvatar"/>
				<div>
					<input type="file" name="avatar" id="avatar" value=""/>
				</div>
			</form>
			<h4>选择上传方式</h4>
			<table class="upload">
				<tr>
					<td class="imageView" rowspan="3">
						<button id="uploadImage">本地上传</button>
						<button id="siteImage">外部图片</button>
						<div id="viewDiv">
							<div id="toplayout"></div>
							<div id="downlayout"></div>
							<div id="leftlayout"></div>
							<div id="rightlayout"></div>
							<div id="mask">
								<div id="draggable"></div>
								<div id="controller"></div>
							</div>
							<canvas></canvas>
						</div>
					</td>
					<td class="description" colspan="2">您上传的图片将会自动生成三种尺寸的头像，请注意中小尺寸的头像是否清晰</td>
				</tr>
				<tr>
					<td class="big_img" rowspan="2">
						<div><canvas></canvas></div>
						大尺寸头像，180×180像素
					</td>
					<td class="middle_img">
						<div><canvas></canvas></div>
						<span>中尺寸头像</span><br/>
						<span>50×50像素</span><br/>
						<span>（自动生成）</span>
					</td>
				</tr>
				<tr>
					<td class="little_img">
						<div><canvas></canvas></div>
						<span>小尺寸头像</span><br/>
						<span>30×30像素</span><br/>
						<span>（自动生成）</span>
						
					</td>
				</tr>
				<tr>
					<td>
						<div id="btn">
							<button>保存</button>
							<button>取消</button>
						</div>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
</body>
</html>

