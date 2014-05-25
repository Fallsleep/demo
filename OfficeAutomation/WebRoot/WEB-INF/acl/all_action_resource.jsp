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
	<title>所有操作资源</title>
<link href="js/acl/treetable/stylesheets/screen.css" rel="stylesheet" media="screen" />
<link href="js/acl/treetable/stylesheets/jquery.treetable.css" rel="stylesheet" type="text/css"/>
<link href="js/acl/treetable/stylesheets/jquery.treetable.theme.default.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/acl/treetable/javascripts/jquery.treetable.js"></script>
<script language="javascript">
	$(function(){
		$(".treetable").treetable({
			 expandable : true,
			 initialState : "expanded"
		});
		//调用初始化函数
		initTables();
		//根据ID将父节点相同操作授权允许
		function permit_parents(parentid, operIndex){
			if(parentid != null){
				var node = $("tr[data-tt-id=" + parentid + "] ins[operIndex=" + operIndex + "]");
				node.removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-permit");
				permit_parents(node.attr("data-tt-parent-id"), operIndex);
			}
		}
		//根据ID将子节点相同操作也授权拒绝
		function deny_children(parentid, operIndex){
			if(parentid != null){
				var nodes = $("ins[data-tt-parent-id=" + parentid + "][operIndex=" + operIndex + "]");
				nodes.each(function(){
					$(this).removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-deny");
					deny_children($(this).attr("id"), operIndex);
				});
			}
		}
		
		$("a.oper,ins").toggle(
			function(){//允许
				if($(this).is("ins")){
					$(this).removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-permit");
					permit_parents($(this).attr("data-tt-parent-id"), $(this).attr("operIndex"));
				}else{
					$(this).children().removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-permit");
					permit_parents($(this).attr("data-tt-parent-id"), $(this).children().attr("operIndex"));
				}
			},
			function(){//拒绝
				if($(this).is("ins")){
					$(this).removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-deny");
					deny_children($(this).attr("id"), $(this).attr("operIndex"));
				}else{
					$(this).children().removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-deny");
					deny_children($(this).children().attr("id"), $(this).children().attr("operIndex"));
				}
			},
			function(){//取消
				if($(this).is("ins")){
					$(this).parent().removeClass("jstree-extends");
					$(this).removeClass("jstree-normal jstree-permit jstree-deny jstree-extends").addClass("jstree-normal");
				}else{
					$(this).removeClass("jstree-extends");
					$(this).children().removeClass("jstree-normal jstree-permit jstree-deny jstree-extends").addClass("jstree-normal");
				}
			}
		);
		
		$("a.oper,ins").dblclick(function(){//继承
			if($(this).is("ins")){
				$(this).parent().addClass("jstree-extends");
				$(this).addClass("jstree-extends");
			}else{
				$(this).addClass("jstree-extends");
				$(this).children().addClass("jstree-extends");
			}
		});
	});
	//初始化授权表格
	function initTables(){
		$.getJSON("system/acl!findActionResourceAcls.action?principalType=${principalType}&principalId=${principalId}",
			function(data){
				for(var i = 0; i < data.length ; ++i){
					var authvo = data[i];
					var node = $("ins[id=" + authvo.resourceId + "][operIndex=" + authvo.operIndex + "]");
					if(authvo.permit == true){
						node.removeClass("jstree-normal jstree-deny jstree-extends").addClass("jstree-permit");
					}else{
						node.removeClass("jstree-normal jstree-permit jstree-extends").addClass("jstree-deny");
					}
					if(authvo.ext == true){
						node.addClass("jstree-extends").parent().addClass("jstree-extends");
					}
				}
			}
		);
	}
	//给操作授权的方法
	function auth(){
		//取出所有节点
		var nodes = $(".treetable").find("ins.jstree-permit,ins.jstree-deny,ins.jstree-extends");
		
		//拼装需要传输到后台的参数
		var param = "principalType=${principalType}&principalId=${principalId}";
		for(var i = 0; i < nodes.length; ++i){
			var node = $(nodes[i]);
			var resourceId = node.attr("id");
			var operIndex = node.attr("operIndex");
			var permit, ext;
			
			if(node.hasClass("jstree-permit")){
				permit = true;
			}else if(node.hasClass("jstree-deny")){
				permit = false;
			}

			if(node.hasClass("jstree-extends")){
				ext = true;
			}else{
				ext = false;
			}
			
			param = param + "&authvos["+ i + "].resourceId=" + resourceId;
			param = param + "&authvos["+ i + "].operIndex=" + operIndex;
			param = param + "&authvos["+ i + "].permit=" + permit;
			param = param + "&authvos["+ i + "].ext=" + ext;
		}
		var url = "system/acl!authActionResource.action";
		$.post(url, param, function(){
			alert("已授权");
			initTables();
		});
	}
	
	function permit_all(){
		$("a.oper").removeClass("jstree-extends");
		$("ins").removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-permit");
	}
	
	function deny_all(){
		$("a.oper").removeClass("jstree-extends");
		$("ins").removeClass("jstree-normal jstree-permit jstree-deny").addClass("jstree-deny");
	}
	
	function extends_all(){
		$("a.oper").removeClass("jstree-extends").addClass("jstree-extends");
	}
	
	function cancel_all(){
		$("a.oper").removeClass("jstree-extends");
		$("ins").removeClass("jstree-normal jstree-permit jstree-deny jstree-extends").addClass("jstree-normal");
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
	<div id="main">
		<table class="treetable">
		<thead>
			<tr>
				<th>操作资源名称</th>
				<th>操作</th>
			</tr>
		</thead>
		<tbody>
		<s:iterator value="#ress" var="res">
			<tr
				data-tt-id="<s:property value="#res.id"/>"
				<s:if test="#res.parent != null">
					data-tt-parent-id="<s:property value="#res.parent.id"/>"
				</s:if>
				valign="top"
			>
				<td>
					<span class="<s:if test="#res.children.size() != 0">folder</s:if><s:else>file</s:else>">
						<s:property value="#res.name"/>
					</span>
				</td>
				<td valign="middle">
					<s:iterator value="opers">
						<a class="oper">								
							<ins class="jstree-normal" operIndex="<s:property value="value.operIndex"/>"
								id="<s:property value="#res.id"/>"
								<s:if test="#res.parent != null">
								data-tt-parent-id="<s:property value="#res.parent.id"/>"
								</s:if>
							></ins>
							<s:property value="value.operName"/>
						</a>
					</s:iterator>
				</td>
			</tr>
		</s:iterator>
		</tbody>
		</table>
	</div>
</body>
</html>

