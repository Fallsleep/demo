	var oTable;
	$(function(){
		oTable = $("#resourceList").dataTable({
			"bPaginate":false,//是否分页
			"bFilter":false,//是否过滤，
			"bSort":false,//是否排序
			"bAutoWidth":false,//自动宽度
			"bInfo":false//是否显示信息
		});
		//点击时选中表行
		$("#resourceList tbody").click(
			function(event){
				/*
				$(oTable.fnSettings().aoData).each(
					function(){
						$(this.nTr).removeClass("row_selected");
					}
				);
				*/
				var ons = oTable.fnGetNodes();
				for(var i = 0; i < ons.length; ++i){
					$(ons[i]).removeClass("row_selected");
				}
				$(event.target.parentNode).addClass("row_selected");
			}
		);
		oTable.css("font-size", "12px");
		$(".dataTables_wrapper").attr("style","min-height:0");
	});
	
	function addOper(){
		window.location = "system/resource!oper_input.action?id=" + resourceId;
	}
	
	function deleteOper(){
		var anSelected = fnGetSelected(oTable);
		if(anSelected.length == 0){
			alert("请选中要删除的操作!");
			return ;
		}
		if(confirm("删除不可恢复，是否确定要删除操作[" + anSelected[0].children[0].innerHTML + "]?")){
			//获取选中人员的ID
			var operSn = anSelected[0].children[0].innerHTML;
			$.get("system/resource!delOper.action?id=" + resourceId + "&operSn=" + operSn, function(){
				oTable.fnDeleteRow(anSelected[0]);
			});
		}
	}
	//获得选中行集合的方法
	function fnGetSelected(oTab){
		var aReturn = new Array();
		var aTrs = oTab.fnGetNodes();
		for(var i = 0; i < aTrs.length; ++i){
			if($(aTrs[i]).hasClass("row_selected")){
				aReturn.push(aTrs[i]);
			}
		}
		return aReturn;
	}