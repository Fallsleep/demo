<!doctype html>
<html class="no-js" lang="en">
<section role="banner">
<article role="main" class="clearfix">
           <div class="post">
             <h2>歡迎光臨</h2>
             <h2>余氏國際業權交易平台</h2>
             <p>YUS INTERNATIONAL GROUP LIMITED 余氏國際集團有限公司 於2009年創立 , 余氏國際 投資方向以黃金，證券，房地產及外匯為主。於2010年更增加投資於 香港電視頻道 " 優質生活台 " 另資金有多方面發展。</p>
             <p>YUS INTERNATIONAL GROUP LIMITED 余氏國際集團有限公司 屬高度外向型。大部分的區域性私募基金均以香港為基地。資金大部分來自香港，並投資到區內公司，包括澳洲、新加坡、印度、韓國、日本及中國內地的黃金，證券，房地產及外匯。</p>
              <a href="http://www.yusgroup.com.hk" class="button left" target="_blank">了解更多 <span class="icon">:</span></a>
           </div>
           <div  role="complementary">
               <!--  <a href="#demo-url">
               <img src="http://new.yusgroup.com.hk/wp-content/uploads/2013/04/yusbgbiglogo1.png" alt="Lorem ipsum dolor...">
               </a> -->
				<?php 
					echo '更新時間: ' . date('D, d M Y H:i:s', strtotime($data['rss']['channel']['lastBuildDate']));
				?>
				<div id="news">
	        		<ul id="news_list"></ul>
					<div id="news_content" style="display:none">
						<ul id= "news_data_ul">
							<?php 
								foreach($data['rss']['channel']['item'] as $feed){
									//echo '<li><a href="' . $feed['link'] . '" rel="noreferrer" target="_blank">' . $feed['title'] . '</a> - ' . $feed['pubDate'] . '</li>';
									
									echo '<li><a href="#" onclick="news_show(\'' . $feed['link'] . '\');return false;" rel="noreferrer">' . $feed['title'] . '</a> - ' . date('m-d H:i', strtotime($feed['pubDate'])) . '</li>';
								}
							?>
						</ul>   				
					</div>
				</div>
           </div>
       </article>
</section> <!-- // banner ends -->

<div id="news_data_div"><iframe id="news_data_frame" width="800" height="600" rel="noreferrer"></iframe></div>

<script type="text/javascript"><!--
var feeds=new Array();
var newsShowNum = 15;
var curNews=-1;
var newsGroup=0;
$(document).ready(function() {

	$("#news_data_div").dialog({
		autoOpen:false,
		modal: true,
		width: 835,
		show: {
			effect: "explode",
			duration: 100
		},
		hide: {
			effect: "blind",
			duration: 100
		},
    	position: ['center',40]
	});
	feeds = $("#news_data_ul li").remove("");
	newsGroup = Math.ceil(feeds.length/newsShowNum);
	newsList = new Array();
	divList = new Array();
	for(var i=0;i<newsGroup;i++){
		divList[i] = $("<div id='news_content"+(i+1)+"'><ul id='news_data_ul"+(i+1)+"'></ul></div>");
		$("#news_content").after(divList[i]);
		curNews = (curNews+1)%newsGroup;
		var newsToShow = feeds.slice(curNews*newsShowNum,curNews*newsShowNum+newsShowNum);
		newsToShow.each(function(key,value){$("#news_data_ul"+(i+1)).append($(value));});
		newsList[i] = $("<li><a href='#news_content"+(i+1)+"'>"+(i+1)+"</a></li>");
		$("#news_list").css("list-style-type","none").append(newsList[i].css("float","left"));
	}
	$("#news").tabs().removeAttr("class");
	$("#news_list").attr("class","ui-helper-reset ui-helper-clearfix");
	$("#news_list li").removeAttr("class");
	$("div").removeClass("ui-tabs-panel ui-widget-content ui-corner-bottom");
});

//function news_page(page){
//	$("#news_data_ul li").remove();
//	curNews = (curNews+1)%newsGroup;
//	var newsToShow = feeds.slice(curNews*newsShowNum,curNews*newsShowNum+newsShowNum);
//	newsToShow.each(function(key,value){$("#news_data_ul").append($(value));});
//}
function news_show(url) {
	//$("#news_data_div").dialog('option', 'title', 'Edit Event');
	//$("#news_data_div").empty();
	//$("#news_data_div").load('<iframe src="'+url+'"></iframe>');
	$("#news_data_frame").attr("src", url);
	$("#news_data_div").dialog("open");
}



--></script>