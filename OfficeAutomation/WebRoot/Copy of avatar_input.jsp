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
	<link href="js/avatar/themes/jquery.ui.core.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.theme.css" rel="stylesheet" type="text/css"/>
	<link href="js/avatar/themes/jquery.ui.button.css" rel="stylesheet" type="text/css"/>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.core.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.widget.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.button.min.js"></script>
	<script type="text/javascript" src="js/avatar/jquery.ui.draggable.min.js"></script>
	<script type="text/javascript">
		$(function(){
			$("button").button();
			$("#uploadImage").click(function(){
				$("#avatar").click();
			});
			$("#avatar").change(function (){
				var avatar = $("#avatar")[0];
				var path;
				if($.browser.msie){
					if($.browser.version == 9.0)
						avatar.blur();
					avatar.select();
					var img = document.createElement("img")
					path = new String(document.selection.createRange().text);
					$(".imageView div img")[0].src = path;
				}else if(avatar.files){
					var fReader = new FileReader();
					fReader.readAsDataURL(avatar.files[0]);
					fReader.onloadend = function(event){
						var img = $(".imageView div img")[0];
						img.src = event.target.result;
					};
				}
				$("img").css("display", "block");
			});
		});
	</script>
	<style type="text/css">
	<!--
	-->
	</style>
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
					<input type="submit" value="submit"/>
				</div>
			</form>
			<h4>选择上传方式</h4>
			<table class="upload">
				<tr>
					<td class="imageView" rowspan="3">
						<button id="uploadImage">本地上传</button>
						<button id="siteImage">外部图片</button>
						<div><img/></div>
					</td>
					<td class="description" colspan="2">您上传的图片将会自动生成三种尺寸的头像，请注意中小尺寸的头像是否清晰</td>
				</tr>
				<tr>
					<td class="big_img" rowspan="2">
						<div><img/></div>
						大尺寸头像，180×180像素
					</td>
					<td class="middle_img">
						<div><img/></div>
						<span>中尺寸头像</span><br/>
						<span>50×50像素</span><br/>
						<span>（自动生成）</span>
					</td>
				</tr>
				<tr>
					<td class="little_img">
						<div><img/></div>
						<span>小尺寸头像</span><br/>
						<span>30×30像素</span><br/>
						<span>（自动生成）</span>
						
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
</body>
</html>

