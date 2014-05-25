<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/inc.jsp" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>所有菜单资源</title>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery.jstree.js"></script>
<script type="text/javascript" src="js/jquery.jstree.aclcheckbox.js"></script>
<script language="javascript">
	var maxMenus = new Number("<s:property value='#menuIds.size()'/>");
	var loadMenu = 0;
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
		//客户区高度减去#menuTree div距离客户区顶部的距离
		clientHeight = clientHeight - $("#menuTree").position().top;
		//动态创建#menuTree div的css
		var css = "#menuTree {width:" + clientWidth + "px;height:" + clientHeight+ "px;overflow:scroll;}";
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
		
		//点击某个节点的菜单 允许
		function permit(node){
			this.permit_node(node);
		}
		//点击某个节点的菜单 拒绝
		function deny(node){
			this.deny_node(node);
		}
		//点击某个节点的菜单 继承
		function extend(node){
			this.extends_node(node);
		}
		//点击某个节点的菜单 取消
		function cancel(node){
			this.cancel_node(node);
		}
		//点击某个节点的菜单 全部允许
		function permitAll(node){
			this.permit_all(node);
		}
		//点击某个节点的菜单 全部拒绝
		function denyAll(node){
			this.deny_all(node);
		}
		//点击某个节点的菜单 全部继承
		function extendAll(node){
			this.extends_all(node);
		}
		//点击某个节点的菜单 全部取消
		function cancelAll(node){
			this.cancel_all(node);
		}
		var contextmenu_items = function(){
			return {
				"permit" : {"label":"允许", "action":permit},
				"deny" : {"label":"拒绝", "action":deny},
				"extend" : {"label":"继承", "action":extend},
				"cancel" : {"label":"取消", "action":cancel},
				"permitAll" : {"label":"全部允许", "action":permitAll},
				"denyAll" : {"label":"全部拒绝", "action":denyAll},
				"extendAll" : {"label":"全部继承", "action":extendAll},
				"cancelAll" : {"label":"全部取消", "action":cancelAll}
			};
		};
		<s:iterator value="#menuIds">
		//将menuContainer变成一棵树！
		$("#menuTree_<s:property/>").jstree({
			"json_data" : {
				"ajax" : {
					"url" : "system/acl!allMenuResourceTree.action?topMenuId=<s:property/>"
				}
			},
			"themes" : {
				"theme" : "classic"
			},
			"contextmenu" : {
				"items" : contextmenu_items
			},
			"plugins" : ["themes","json_data", "ui", "aclcheckbox", "contextmenu"]
		});
		$("#menuTree_<s:property/>").bind(
			"loaded.jstree",
			function(event){
				initTables();
				$("#menuTree_<s:property/>").jstree("open_all", -1);
			}
		);
		$("#menuTree_<s:property/>").css("font-size", "12px");
		</s:iterator>
	});
	//初始化授权表格
	function initTables(){
		loadMenu++;
		if(loadMenu >= maxMenus){
			$.getJSON("system/acl!findMenuAcls.action?principalType=${principalType}&principalId=${principalId}",
				function(data){
					cancel_all();
					for(var i = 0; i < data.length ; ++i){
						var authvo = data[i];
						var node = $("#" +authvo.resourceId);
						if(authvo.permit == true){
							node.removeClass("jstree-normal jstree-deny jstree-extends").addClass("jstree-permit");
						}else{
							node.removeClass("jstree-normal jstree-permit jstree-extends").addClass("jstree-deny");
						}
						if(authvo.ext == true){
							node.addClass("jstree-extends");
						}
					}
				}
			);
		}
	}
	//给菜单授权的方法
	function auth(){
		//取出所有节点
		var nodes = getAllCheckedNodes();
		
		//拼装需要传输到后台的参数
		var param = "principalType=${principalType}&principalId=${principalId}";
		for(var i = 0; i < nodes.length; ++i){
			var resourceId = nodes[i].attr("id");
			var operIndex = 0;
			var permit, ext;
			
			if(nodes[i].hasClass("jstree-permit")){
				permit = true;
			}else if(nodes[i].hasClass("jstree-deny")){
				permit = false;
			}

			if(nodes[i].hasClass("jstree-extends")){
				ext = true;
			}else{
				ext = false;
			}
			
			param = param + "&authvos["+ i + "].resourceId=" + resourceId;
			param = param + "&authvos["+ i + "].operIndex=" + operIndex;
			param = param + "&authvos["+ i + "].permit=" + permit;
			param = param + "&authvos["+ i + "].ext=" + ext;
		}
		var url = "system/acl!authMenu.action";
		$.post(url, param, function(data){
			alert("已授权");
			loadMenu = 6;
			initTables();
		});
	}
	//获取所有已授权节点
	function getAllCheckedNodes(){
		var nodes = new Array();
		<s:iterator value="#menuIds">
		var allChecked<s:property/> = $("#menuTree_<s:property/>").jstree("get_all_auths_nodes");
		for(var i = 0; i < allChecked<s:property/>.length; ++i){
			nodes.push($(allChecked<s:property/>[i]));
		}
		</s:iterator>
		return nodes;
	}
	
	function permit_all(){
		<s:iterator value="#menuIds">
			$("#menuTree_<s:property/>").jstree("permit_all");
		</s:iterator>
	}
	
	function deny_all(){
		<s:iterator value="#menuIds">
			$("#menuTree_<s:property/>").jstree("deny_all");
		</s:iterator>
	}
	
	function extends_all(){
		<s:iterator value="#menuIds">
			$("#menuTree_<s:property/>").jstree("extends_all");
		</s:iterator>
	}
	
	function cancel_all(){
		<s:iterator value="#menuIds">
			$("#menuTree_<s:property/>").jstree("cancel_all");
		</s:iterator>
	}
</script>
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	font-size:12px;
}
-->
</style>
</head>
<body>
	<a href="system/acl!allMenuResource.action?principalType=${principalType }&principalId=${principalId }">菜单授权</a>&nbsp;
	<a href="system/acl!allActionResource.action?principalType=${principalType }&principalId=${principalId }">操作授权</a>&nbsp;
	<a href="javascript:auth()">保存授权</a>&nbsp;|
	<a href="javascript:permit_all()">全部允许</a>&nbsp;
	<a href="javascript:deny_all()">全部拒绝</a>&nbsp;
	<a href="javascript:extends_all()">全部继承</a>&nbsp;
	<a href="javascript:cancel_all()">全部取消</a>
	<hr/>
	<div id="menuTree">
		<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<s:iterator value="#menuIds">
				<td width="150" valign="top">
					<div id="menuTree_<s:property/>"></div>
				</td>
				</s:iterator>
			</tr>
		</table>
	</div>
</body>
</html>

