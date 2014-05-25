<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>CMS 后台管理工作平台</title>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.custom.min.js"></script>
<script type="text/javascript" src="js/jquery.jstree.js"></script>
<script language="javascript">
	$(function(){
		//计算当前页面的高度开始
		var clientHeight, clientWidth;
		if($.browser.msie){
			//如何是IE浏览器document.body.clientHeight属性得到窗口高度
			clientHeight = document.body.clientHeight;
			clientWidth = document.body.clientWidth;
		} 
		else{// w3c
			clientHeight = self.innerHeight;
			clientWidth = self.innerWidth;
		}
		//动态创建#menuContainer div的css
		var css = "#menuContainer,.jstree-apple > ul {width:" + clientWidth + "px;height:" + clientHeight+ "px;overflow:auto;}";
		var style=document.createElement("style");
	    style.setAttribute("type", "text/css");
	  
	    if(style.styleSheet){// IE
	        style.styleSheet.cssText = css;
	    } else {// w3c
	        var cssText = document.createTextNode(css);
	        style.appendChild(cssText);
	    }
	    
	    var heads = document.getElementsByTagName("head");
	    if(heads.length)
	        heads[0].appendChild(style);
	    else
	        document.documentElement.appendChild(style);
		//将menuContainer变成一棵树！
		$("#menuContainer").jstree({
			"json_data" : {
				"ajax" : {
					"url" : "system/index!menu.action?_rnd="+ Math.random()*1E16/* ,main、center、left放入WEB-INF目录下，无法直接访问了，不用考虑ajax请求失败的情况了
					"error" : function(XMLHttpRequest, textStatus){
						if(XMLHttpRequest.status == 408){
							parent.parent.window.location = "index.jsp";
						}
					} */
				}
			},
			"themes" : {
				"theme" : "apple"
			},
			"plugins" : ["themes","json_data", "ui"]
		});
		
		//给所有的链接设置其target属性为rightFrame，即在右边打开链接地址
		//$("a").attr("target","rightFrame");
		$("#menuContainer").bind(
			"select_node.jstree",
			function(event,data){
				//取li标签下A标签的href属性
				var href = $(data.args[0]).attr("href");
				if(href != "" && href != "#"){
					$(parent.document).find("#rightFrame").attr("src", href);
				}
			}
		);
	});
</script>
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	font-size:12px;
	overflow:auto;
}
 ul{
	width:100%
} 
-->
</style>
</head>
<body>
<div id="menuContainer"  style="height:100%;width:100%"></div>
</body>
</html>

