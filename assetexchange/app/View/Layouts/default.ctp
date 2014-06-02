<?php
/**
 *
 * PHP 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @linkhttp://cakephp.org CakePHP(tm) Project
 * @package app.View.Layouts
 * @since CakePHP(tm) v 0.10.0.1076
 * @license MIT License (http://www.opensource.org/licenses/mit-license.php)
 */

$cakeDescription = __d('cake_dev', '余氏國際');
?>
<!DOCTYPE html>
<html>
<head>
	<?php echo $this->Html->charset(); ?>
	<title>
		<?php echo $cakeDescription ?>:
		<?php echo $title_for_layout; ?>
	</title>
	<?php
		echo $this->Html->meta('icon');
		//echo $this->Html->script('https://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js');
		echo $this->Html->css('cake.generic');
		
		echo $this->Html->script('jquery.min');
		//echo $this->Html->script('jquery.noreferrer');
		echo $this->Html->script('common');
		echo $this->Html->css('common');
		echo $this->Html->css('style');
		echo $this->Html->css('raphaelicons');
		echo $this->Html->css('main');

		echo $this->fetch('meta');
		echo $this->fetch('css');
		echo $this->fetch('script');
		
		if(isset($cssIncludes)){
			foreach($cssIncludes as $css){
				echo $this->Html->css($css);
			}
		}
		
		if(isset($jsIncludes)){
			foreach($jsIncludes as $js){
				echo $this->Html->script($js);
			}
		}
	?>
	<!--[if lt IE 9]>
	<script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
	<script>
		$(document).ready(function(){
			$.ajax({
			    url: '<?php echo Router::url(array('controller' => 'Assets', 'action' => 'getAllAssetsAjax')); ?>',
			    cache: false,
			    type: 'POST',
			    dataType: 'json',
			    success: function (data) {
			    	load_asset(data);
	                	    	
			    	marquee('#asset_ul', 4);
			    }
			});
			$.ajax({
			    url: '<?php echo Router::url(array('controller' => 'News', 'action' => 'getTopTenNews')); ?>',
			    cache: false,
			    type: 'POST',
			    dataType: 'json',
			    success: function (data) {
			    	load_news(data);	                	    	
			    	marquee('#news_ul', 2);
			    }

			});
			
		});
		function marquee(id, num){
            //播放速度
            var speed = 4000;
            //控制范围
            var block = id + ' li';
            //需要显示的内容条目数
            var eq = num;
            var h = 0;
            $(block).slice(0,eq).css('display', 'block');
            if ($(block).length > eq) {//如果内容数目大于需要滚动的数目，开始滚动！
                //隐藏除了第一个的其它所有节点
                $(block).slice(eq).css('display', 'none');
                //播放开始
                h = setInterval('scrollContent("' + block + '",' + eq + ',3)', speed);
                $(id).mouseout(function() {
                    h = setInterval('scrollContent("' + block + '",' + eq + ',3)', speed);
                });
                $(id).mouseover(function() {
                    clearInterval(h);
                });
            }
		}

        function scrollContent(block, eq, type) {
            //获取第节点
            var firstNode = $(block);
            //动画效果
            switch (type) {
                case 1:
                    animation_out = { height: 'hide' };
                    animation_in = { height: 'show' };
                    break;
                case 2:
                    animation_out = { opacity: 'hide' };
                    animation_in = { opacity: 'show' };
                    break;
                case 3:
                    animation_out = { height: 'hide', opacity: 'hide' };
                    animation_in = { height: 'show', opacity: 'show' };
                    break;
                default: '';
            }
            //开始动画
            firstNode.slice(0,eq).animate(animation_out, 2000, function() {//隐藏
                //克隆.追加到最后.隐藏
                $(this).clone().appendTo($(this).parent()).css('display', 'none').css('float','left');
                //显示第二个节点内容
                firstNode.slice(eq,eq*2).removeAttr('style').animate(animation_in, 2000).css('float','left');
                //删除第一个节点内容
                $(this).remove();
            });
        }

		function load_asset(data){			
			$.each(data.data,function(index,asset){
				var output = "";
				output += "<li><a href='<?php echo Router::url(array('controller' => 'assets', 'action' => 'view')) . '/'?>" + asset.asset_id + "'>" + asset.symbol + "</a>\t";
				output += asset.name + "\t";
				output += Number(asset.close_price).toFixed(3) + " ";
				if (asset.change_per != 0){
					var cp = ((asset.change_per > 0)?"rise":"fall");
					
					output += "(<span class='" + cp + "'>" + Math.abs(asset.change_per).toFixed(2) + "%</span>)</td>";
				}
				else{
					output += "(0.00%)";
				}
				output += "</li>";
				$('#asset_ul').append($(output).css('display','none').css('float','left'));
			});
		}
		function load_news(data){			
			$.each(data,function(index,news){
				var output = "";
				//var date = new Date();
				//date.setTime(Date.parse(news.pubDate));
				//alert(date.toLocaleString());
				//下面的是点击新闻弹出对话框的代码，想正常使用要将News/index里的37行，46-59行，85-91行移植到本文件
				//output += '<li><a href="#" onclick="news_show(\'' + news.link + '\');return false;" rel="noreferrer">' + news.title + '</a> - ' + news.pubDate + '</li>'
				output += '<li><a href="' + news.link + '" target="_blank">' + news.title + '</a> - ' + news.pubDate + '</li>'
				$('#news_ul').append($(output).css('display','none').css('float','left'));
			});
		}
	</script>
</head>
<!--[if lt IE 7]> <body class="ie6 oldies"> <![endif]-->
<!--[if IE 7]><body class="ie7 oldies"> <![endif]-->
<!--[if IE 8]><body class="ie8 oldies"> <![endif]-->
<!--[if gt IE 8]><!--><body><!--<![endif]-->

<!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->


<body>
	<div id="container">
		<header class="clearfix">
			<div class="container">
				<?php echo $this->Html->link('余氏國際業權交易平台', array('controller' => 'users', 'action' => 'home'), array('id' => 'logo')); ?>
				
				
			<div class="social-icons">
			<h1><?php //echo $this->Html->link($cakeDescription, 'http://cakephp.org'); ?></h1>
			<?php 
				if ($this->Session->check('Auth.User')){
					echo $this->Html->link('你好 '.$this->Session->read('Auth.User')['name'] . ', ',  array('controller' => 'Users', 'action' => 'home'));
					echo '&nbsp;';
					//var_dump($this->Session->read('Auth.User'));
					echo $this->Html->link('登出', array('controller' => 'users', 'action' => 'logout'));
				  } ?>
			</div>
				
			<!--  	<ul class="social-icons">
					<li><a href="http://www.facebook.com/blog.cssjuntion" class="icon flip">^</a></li>
					<li><a href="" class="icon">T</a></li>
					<li><a href="http://www.twitter.com/cssjunction" class="icon">^</a></li>
				</ul> -->
				<nav class="clearfix">
					<ul role="navigation">
						<li>
							<?php
							echo $this->Html->link(
								$this->Html->tag('span', 'Q', array('class' => 'icon')).'最新資訊',
								array('controller' => 'News', 'action' => 'index'),
								array('escape' => false)
							) 
							?>
						</li>
						<li>
							<?php
							echo $this->Html->link(
								$this->Html->tag('span', 'L', array('class' => 'icon')).'我的帳戶',
								array('controller' => 'Users', 'action' => 'home'),
								array('escape' => false)
							) 
							?>
						</li>
						<li>
							<?php
							echo $this->Html->link(
								$this->Html->tag('span', 'S', array('class' => 'icon')).'物業資訊',
								array('controller' => 'Assets', 'action' => 'index_ajax'),
								array('escape' => false)
							) 
							?>
						</li>
						<li>
							<?php
							echo $this->Html->link(
								$this->Html->tag('span', 'S', array('class' => 'icon')).'物業檢索',
								array('controller' => 'Assets', 'action' => 'search'),
								array('escape' => false)
							) 
							?>
						</li>						
						<li>
							<?php
							echo $this->Html->link(
								$this->Html->tag('span', 'I', array('class' => 'icon')).'喜愛的物業',
								array('controller' => 'UserFavourites', 'action' => 'index_ajax'),
								array('escape' => false)
							) 
							?>
						</li>						
							<?php
							if ($this->Session->check('Auth.User') && $this->Session->read('Auth.User')['Role'] == 'Admin'){
								echo '<li>' . $this->Html->link(
									$this->Html->tag('span', 'Ñ', array('class' => 'icon')).'平台管理',
									array('controller' => 'Assets', 'action' => 'admin_index'),
									array('escape' => false)
								) . '</li>';
							}
							?>
					</ul>
				</nav>
			</div>
		</header>
	   <section role="banner">
       <hgroup style="text-align: center">
          <?php echo isset($subtitle_for_layout)?$subtitle_for_layout:""; ?>
	          <ul id="asset_ul" style="list-style:none;width:960px;margin:1em auto"  ></ul>
	          <br>
	          <ul id="news_ul" style="list-style:none;width:960px;margin:1em auto"></ul>
       </hgroup>
       </section> 
       
		
        <section class="container clearfix">
		<div id="content">

			<?php echo $this->Session->flash(); ?>

			<?php echo $this->fetch('content'); ?>
		</div>
		</section>
		<!--
		<div id="footer">
			<?php echo $this->Html->link(
					$this->Html->image('cake.power.gif', array('alt' => $cakeDescription, 'border' => '0')),
					'http://www.cakephp.org/',
					array('target' => '_blank', 'escape' => false)
				);
			?>
		</div>-->
	</div>
	<?php echo $this->element('sql_dump'); ?>
	
	<footer role="contentinfo">
      <p>
        <span class="left">Copyright © 2013 Yus International Bullion Ltd. <a href="#">回到頁頂</a></span>
        <?php
			echo $this->Html->link(
				'最新資訊',
				array('controller' => 'news', 'action' => 'index'),
				array('escape' => false)
			) 
		?> | 
		<?php
			echo $this->Html->link(
				'我的帳戶',
				array('controller' => 'users', 'action' => 'home'),
				array('escape' => false)
			) 
		?> | 
		<?php
			echo $this->Html->link(
				'物業資訊',
				array('controller' => 'Assets', 'action' => 'index_ajax'),
				array('escape' => false)
			) 
		?> | 
		<?php
			echo $this->Html->link(
				'物業檢索',
				array('controller' => 'Assets', 'action' => 'search'),
				array('escape' => false)
			) 
		?> | 
		<?php
			echo $this->Html->link(
				'喜愛的物業',
				array('controller' => 'UserFavourites', 'action' => 'index_ajax'),
				array('escape' => false)
			) 
		?>
		<?php
			if ($this->Session->check('Auth.User') && $this->Session->read('Auth.User')['Role'] == 'Admin'){
				echo ' | ' . $this->Html->link(
					'平台管理',
					array('controller' => 'Assets', 'action' => 'admin_index'),
					array('escape' => false)
				);
			}
		?>
      </p>
  </footer>
	
</body>
</html>
