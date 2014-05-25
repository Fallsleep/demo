(function($){
	var RectPos = function (name, rect){
		this.name = name;
		this.init = function(rect){
			if(rect != null){
				this.top = rect.top;
				this.left = rect.left;
				this.right = rect.right;
				this.bottom = rect.bottom;
				this.width = this.right - this.left;
				this.height = this.bottom - this.top;
			}
		};
		this.init(rect);
		this.setLen = function(len){ this.width = len; this.height = len; this.len = len;};
	};
	
	var instances = [],
		focused_instance = -1,
		plugins = {};
	$.fn.avatar = function(settings){
		var returnValue = this;
		if(typeof settings != "object"){
			alert("settings对象格式错误");
		}
		this.each(function(){
			var instance_id = $.data(this, "avatar-id"),
				s = false;
			//如果实例存在，则先销毁
			if(typeof instance_id !== "undefined" && instances[instance_id]) { instances[instance_id].destroy(); }
			//向数组末尾插入一个空对象
			instance_id = parseInt(instances.push({}),10) - 1;
			//将实例ID存入容器元素中
			$.data(this, "avatar-id", instance_id);
			//清空所有插件
			if(!settings) { settings = {}; }
			settings.plugins = $.isArray(settings.plugins) ? settings.plugins : $.avatar.defaults.plugins;
			if($.inArray("core", settings.plugins) === -1) { settings.plugins.unshift("core"); }
			
			s = $.extend(true, {}, $.avatar.defaults, settings);
			s.plugins = settings.plugins;
			//遍历avatar已定义的插件，判断插件i是否在s.plugins中，如果不在，则将s下索引为i的属性（设置）删除
			//虽然plugins = {}，但是在$.avatar.plugin()方法中plugins[pname] = pdata;调用该方法后插件已经加入到plugins了
			$.each(plugins, function (i, val) { if($.inArray(i, s.plugins) === -1) { s[i] = null; delete s[i]; } });
			//
			instances[instance_id] = new $.avatar._instance(instance_id, $(this).addClass("avatar avatar-" + instance_id), s); 
			// init all activated plugins for this instance
			$.each(instances[instance_id]._get_settings().plugins, function (i, val) { instances[instance_id].data[val] = {}; });
			$.each(instances[instance_id]._get_settings().plugins, function (i, val) { if(plugins[val]) { plugins[val].__init.apply(instances[instance_id]); } });
			// initialize the instance
			instances[instance_id].init();
		});
		return returnValue;
	};
	$.avatar = {
		defaults : {
			plugins : []
		},
		_focused : function () { return instances[focused_instance] || null; },
		_instance : function (index, container, settings) { 
			// for plugins to store data in
			this.data = { core : {} };
			this.get_settings	= function () { return $.extend(true, {}, settings); };
			this._get_settings	= function () { return settings; };
			this.get_index		= function () { return index; };
			this.get_container	= function () { return container; };
			this._set_settings	= function (s) { 
				settings = $.extend(true, {}, settings, s);
			};
		},
		_fn : { },
		plugin : function (pname, pdata) {
			pdata = $.extend({}, {
				__init		: $.noop, 
				__destroy	: $.noop,
				_fn			: {},
				defaults	: false
			}, pdata);
			plugins[pname] = pdata;

			$.avatar.defaults[pname] = pdata.defaults;
			$.each(pdata._fn, function (i, val) {
				val.plugin		= pname;
				val.old			= $.avatar._fn[i];
				$.avatar._fn[i] = function () {
					var rslt,
						func = val,
						args = Array.prototype.slice.call(arguments),
						rlbk = false;

					// Check if function belongs to the included plugins of this instance
					do {
						if(func && func.plugin && $.inArray(func.plugin, this._get_settings().plugins) !== -1) { break; }
						func = func.old;
					} while(func);
					if(!func) { return; }

					// context and function to trigger events, then finally call the function
					if(i.indexOf("_") === 0) {
						rslt = func.apply(this, args);
					}
					else {
						rslt = func.apply(
							$.extend({}, this, { 
								__callback : function (data) { 
									this.get_container().triggerHandler( i + '.avatar', { "inst" : this, "args" : args, "rslt" : data, "rlbk" : rlbk });
								},
								__rollback : function () { 
									rlbk = this.get_rollback();
									return rlbk;
								},
								__call_old : function (replace_arguments) {
									return func.old.apply(this, (replace_arguments ? Array.prototype.slice.call(arguments, 1) : args ) );
								}
							}), args);
					}

					// return the result
					return rslt;
				};
				$.avatar._fn[i].old = val.old;
				$.avatar._fn[i].plugin = pname;
			});
		},
		
	};
	
	$.avatar._fn = $.avatar._instance.prototype = {};
	
	$.avatar.plugin("core", {
		defaults : { 
			ajax : false,
		},
		_fn : { 
			init : function () {
				this.set_focus();
				this.create_elements();
				this.init_global();
				this._get_node("#avatar-draggable").position({
					of : this._get_node("#avatar-mask"),
					my : "center middle",
					at : "center middle"
				});
				this._get_node("#avatar-uploadImage").click($.proxy(function(){this._get_node("#uploadAvatar").click();}, this));
				//注册input file值改变事件，进行图片加载
				this._get_node("#uploadAvatar").change($.proxy(function(){
					this.data.core.direction = 0;//0无、1右转90、2旋转180、3左转90
					this.loadImage(0);
				}, this));

				//注册左转右转事件
				this._get_node("#avatar-turnleft").click($.proxy(this, "loadImage", -1));
				this._get_node("#avatar-turnright").click($.proxy(this, "loadImage", 1));
				
				this._get_node("#avatar-controller").mousedown($.proxy(this, "resizeSelector"));
				this._get_node("#avatar-draggable").draggable({
					drag : $.proxy(function(){
						this.generateCss("block");
						this.generateAvatarCss(true);
					}, this),
					containment : "#avatar-mask"
				});
				this.generateCss("none");
				this.position();
				//注册上传按钮
				this._get_node("#avatar-submit").click($.proxy(function(){
					this.upload();
				}, this));
			},
			destroy	: function () { 
			},
			// deal with focus
			set_focus	: function () { 
				var f = $.avatar._focused();
				if(f && f !== this) {
					f.get_container().removeClass("avatar-focused"); 
				}
				if(f !== this) {
					this.get_container().addClass("avatar-focused"); 
					focused_instance = this.get_index(); 
				}
				this.__callback();
			},
			_get_node : function(selector){
				return this.get_container().find(selector);
			},
			create_elements : function(){
				var avatarHtml = "<input type='file' name='uploadAvatar' id='uploadAvatar'/><h4>选择上传方式</h4>";
				avatarHtml += "<table class='avatar-upload'><tr><td id='avatar-choose'colspan='4'>仅支持JPG、PNG、GIF（非动态图）格式，文件小于200K<br/><br/>";
				avatarHtml += "<button id='avatar-uploadImage'>本地图片</button><button id='avatar-siteImage'>外部图片</button></td></tr>";
				avatarHtml += "<tr><td class='avatar-imageView' rowspan='3'>";
				avatarHtml += "<div id='avatar-viewDiv'><div id='avatar-toplayout'></div><div id='avatar-downlayout'></div>";
				avatarHtml += "<div id='avatar-leftlayout'></div><div id='avatar-rightlayout'></div>";
				avatarHtml += "<div id='avatar-mask'><div id='avatar-draggable'></div><div id='avatar-controller'></div></div><canvas></canvas></div></td>";
				avatarHtml += "<td class='avatar-blank' rowspan='3'></td>";
				avatarHtml += "<td class='avatar-description' colspan='2'>您上传的图片将会自动生成三种尺寸的头像，请注意中小尺寸的头像是否清晰</td></tr>";
				avatarHtml += "<tr><td class='avatar-big-img' rowspan='2'><div><canvas width='180' height='180'></canvas></div>大尺寸头像，180×180像素<br/><span></span></td>";
				avatarHtml += "<td class='avatar-middle-img'><div><canvas width='50' height='50'></canvas></div><span>中尺寸头像</span><br/><span>50×50像素</span><br/><span>（自动生成）</span></td></tr>";
				avatarHtml += "<tr><td class='avatar-little-img'><div><canvas width='30' height='30'></canvas></div><span>小尺寸头像</span><br/><span>30×30像素</span><br/><span>（自动生成）</span></td></tr>";
				avatarHtml += "<tr><td class='avatar-turn'><span id='avatar-turnleft'>左转90度</span><span id='avatar-turnright'>右转90度</span></td></tr></table>";
				avatarHtml += "<div id='avatar-btn'><button id='avatar-submit'>保存</button><button id='avatar-reset'>取消</button></div>";
				var _this = this.get_container();
				_this.append(avatarHtml);
				//_this.children().wrapAll("<fieldset><legend>上传头像</legend></fieldset>");
				_this.find("button").each(function(){$(this).button();});
			},
			init_global : function(){
				this.data.core.maskDiv = new RectPos("maskDiv",this._get_node("#avatar-mask")[0].getBoundingClientRect());
				this.data.core.viewImg = new RectPos("viewImg");
				this.data.core.dragDiv = new RectPos("dragDiv");
				this.data.core.topDiv = new RectPos("topDiv");
				this.data.core.downDiv = new RectPos("downDiv");
				this.data.core.leftDiv = new RectPos("leftDiv");
				this.data.core.rightDiv = new RectPos("rightDiv");
				this.data.core.imgWidth = 0;
				this.data.core.imgHeight = 0;
				this.data.core.ctx4View = this._get_node(".avatar-imageView div canvas")[0].getContext("2d");
				this.data.core.ctxBig = this._get_node(".avatar-big-img div canvas")[0].getContext("2d");
				this.data.core.ctxMiddle = this._get_node(".avatar-middle-img div canvas")[0].getContext("2d");
				this.data.core.ctxLittle = this._get_node(".avatar-little-img div canvas")[0].getContext("2d");
			},
			position : function(){
				this._get_node("#avatar-controller").position({
					of : this._get_node("#avatar-draggable"),
					my : "center middle",
					at : "right bottom"
				});
				this._get_node("#avatar-toplayout").position({
					of : this._get_node("#avatar-viewDiv"),
					my : "left top",
					at : "left top",
					offset : "1 0"
				});
				this._get_node("#avatar-downlayout").position({
					of : this._get_node("#avatar-viewDiv"),
					my : "left bottom",
					at : "left bottom",
					offset : "1 0"
				});
				this._get_node("#avatar-leftlayout").position({
					of : this._get_node("#avatar-draggable"),
					my : "right",
					at : "left"
				});
				this._get_node("#avatar-rightlayout").position({
					of : this._get_node("#avatar-draggable"),
					my : "left",
					at : "right"
				});
			},
			loadImage : function (direction){
				var avatar = this._get_node("#uploadAvatar")[0];
				if(avatar.files){
					if(window.FileReader){
						this.data.core.fReader = new FileReader();
						this.data.core.fReader.readAsDataURL(avatar.files[0]);
						this.data.core.fReader.onloadend = $.proxy(this, "loadFileReader", direction);
					}else{
						alert("您使用的浏览器不支持部分HTML5特性，无法使用该方式预览图片！");
					}
				}
			},
			loadFileReader : function (direction,event){
				//direction -1左转，1右转,0无
				this.data.core.direction = (this.data.core.direction + direction)%4;//0无、1右转90、2旋转180、3左转90
				if(this.data.core.direction < 0) this.data.core.direction += 4;
				this.data.core.img = new Image();
				this.data.core.img.src = event.target.result;
				if(this.data.core.direction == 0 || this.data.core.direction == 2){
					this.data.core.imgWidth = this.data.core.img.width;
					this.data.core.imgHeight = this.data.core.img.height;
				} else {
					this.data.core.imgWidth = this.data.core.img.height;
					this.data.core.imgHeight = this.data.core.img.width;
				} 
				
				this.data.core.img.onload = $.proxy(function(){
					//为画布加载文件
					this.data.core.ctx4View.save();
					this._get_node(".avatar-imageView div canvas").attr("width", this.data.core.imgWidth).attr("height", this.data.core.imgHeight);
					this.data.core.ctx4View.rotate(this.data.core.direction * Math.PI / 2);
					if(this.data.core.direction == 0 ){
						this.data.core.ctx4View.drawImage(this.data.core.img, 0, 0);
					}else if(this.data.core.direction == 1){
						this.data.core.ctx4View.drawImage(this.data.core.img, 0, -this.data.core.img.height);
					}else if(this.data.core.direction == 2){
						this.data.core.ctx4View.drawImage(this.data.core.img, -this.data.core.img.width, -this.data.core.img.height);
					}else if(this.data.core.direction == 3){
						this.data.core.ctx4View.drawImage(this.data.core.img, -this.data.core.img.width, 0);
					}
					this.data.core.ctx4View.restore();
					this.generateAvatarCss(true);
					this._get_node(".avatar-big-img span").text("上传数据大小" + (this.data.core.ctxBig.canvas.toDataURL().length/1024).toFixed(2) + "K");
				}, this);
				this.initPosInfo();
				this.generateImgae();
				this._get_node("#avatar-btn").css("display", "block");
			},//加载图片时初始化位置信息
			initPosInfo : function (){
				if(this.data.core.imgWidth < this.data.core.imgHeight){
					this.data.core.viewImg.ratio = this.data.core.imgHeight/300;
					this.data.core.viewImg.width = this.data.core.imgWidth/this.data.core.viewImg.ratio;
					this.data.core.viewImg.height = 300;
					this.data.core.viewImg.left = this.data.core.maskDiv.left + (300 - this.data.core.viewImg.width)/2;
					this.data.core.viewImg.top = this.data.core.maskDiv.top;
					this.data.core.dragDiv.setLen(this.data.core.viewImg.width);
				}else{
					this.data.core.viewImg.ratio = this.data.core.imgWidth/300;
					this.data.core.viewImg.width = 300;
					this.data.core.viewImg.height = this.data.core.imgHeight/this.data.core.viewImg.ratio;
					this.data.core.viewImg.left = this.data.core.maskDiv.left;
					this.data.core.viewImg.top = this.data.core.maskDiv.top + (300 - this.data.core.viewImg.height)/2;
					this.data.core.dragDiv.setLen(this.data.core.viewImg.height);
				}
				if(this.data.core.dragDiv.len > 180){
					this.data.core.dragDiv.setLen(180);
				}
			},
			generateImgae : function (){
				this._get_node(".avatar-imageView div canvas, #avatar-mask").css({
					"width" : this.data.core.viewImg.width + "px",	"height" : this.data.core.viewImg.height + "px",
					"top" : this.data.core.viewImg.top + "px",	"left" : this.data.core.viewImg.left +  "px",
					"display" : "block"
				});
				this._get_node("#avatar-draggable").css({
					"width" : this.data.core.dragDiv.width + "px",	"height" : this.data.core.dragDiv.height + "px",
					"display" : "block"
				});
				this._get_node("#avatar-draggable").position({
					of : this._get_node("#avatar-mask"),
					my : "center middle",
					at : "center middle"
				});
				this._get_node("#avatar-controller").css({"display" : "block"});
				this.generateCss("block");
				this.generateAvatarCss(false);
			},
			//生成样式
			generateCss : function (display){
				this.data.core.dragDiv.init(this._get_node("#avatar-draggable")[0].getBoundingClientRect());
				var rect = this._get_node("#avatar-viewDiv")[0].getBoundingClientRect();
				this.data.core.topDiv.height = this.data.core.dragDiv.top - rect.top;
				this.data.core.downDiv.height = rect.bottom - this.data.core.dragDiv.bottom;
				this.data.core.leftDiv.width = this.data.core.dragDiv.left - rect.left - 1;
				this.data.core.rightDiv.width = rect.right - this.data.core.dragDiv.right - 1;
				this._get_node("#avatar-toplayout").css({"width" : "300px",	"height" : this.data.core.topDiv.height + "px", "display" : display});
				this._get_node("#avatar-downlayout").css({"width" : "300px", "height" : this.data.core.downDiv.height + "px", "display" : display});
				this._get_node("#avatar-leftlayout").css({"width" : this.data.core.leftDiv.width + "px", "height" : this.data.core.dragDiv.height + "px", "display" : display});
				this._get_node("#avatar-rightlayout").css({"width" : this.data.core.rightDiv.width + "px", "height" : this.data.core.dragDiv.height + "px", "display" : display});
				this.position();
			},
			/*generateAvatarCss : function (move){能剪裁，但是翻转图片后无法处理
				var rect = this._get_node("#avatar-draggable")[0].getBoundingClientRect();
				var cutLeft = (rect.left - this.data.core.viewImg.left + 0.32)*this.data.core.viewImg.ratio;
				var cutTop = (rect.top - this.data.core.viewImg.top)*this.data.core.viewImg.ratio;
				var cutWidth = this.data.core.dragDiv.width*this.data.core.viewImg.ratio;
				var cutHeight = this.data.core.dragDiv.height*this.data.core.viewImg.ratio;
				
				this.data.core.ctxBig.drawImage(this.data.core.img, cutLeft, cutTop, cutWidth, cutHeight, 0, 0, 180, 180);
				this.data.core.ctxMiddle.drawImage(this.data.core.img, cutLeft, cutTop, cutWidth, cutHeight, 0, 0, 50, 50);
				this.data.core.ctxLittle.drawImage(this.data.core.img, cutLeft, cutTop, cutWidth, cutHeight, 0, 0, 30, 30);
			},*/
			generateAvatarCss : function (move){
				var rect = this._get_node("#avatar-draggable")[0].getBoundingClientRect();
				var cutLeft = (rect.left - this.data.core.viewImg.left + 0.32)*this.data.core.viewImg.ratio;
				var cutTop = (rect.top - this.data.core.viewImg.top)*this.data.core.viewImg.ratio;
				var cutWidth = this.data.core.dragDiv.width*this.data.core.viewImg.ratio;
				var cutHeight = this.data.core.dragDiv.height*this.data.core.viewImg.ratio;
				this.data.core.imgData = this.data.core.ctx4View.getImageData(cutLeft, cutTop, cutWidth, cutHeight);
				this._get_node(".avatar-big-img div canvas").attr("width", this.data.core.imgData.width).attr("height", this.data.core.imgData.height);
				this.data.core.ctxBig.putImageData(this.data.core.imgData, 0, 0);
				this._get_node(".avatar-big-img div canvas").css({"width": "180px", "height": "180px","display":"block"});
				
				this._get_node(".avatar-middle-img div canvas").attr("width", this.data.core.imgData.width).attr("height", this.data.core.imgData.height);
				this.data.core.ctxMiddle.putImageData(this.data.core.imgData, 0, 0);
				this._get_node(".avatar-middle-img div canvas").css({"width": "50px", "height": "50px","display":"block"});
				
				this._get_node(".avatar-little-img div canvas").attr("width", this.data.core.imgData.width).attr("height", this.data.core.imgData.height);
				this.data.core.ctxLittle.putImageData(this.data.core.imgData, 0, 0);
				this._get_node(".avatar-little-img div canvas").css({"width": "30px", "height": "30px","display":"block"});
 			},
			resizeSelector : function (){
				this._get_node("*").mouseup($.proxy(function(){
					this.get_container().css("cursor", "default");
					this._get_node("#avatar-mask").css("cursor", "default");
					this._get_node("#avatar-draggable").css("cursor", "move");
					this._get_node("*").unbind("mousemove");
				}, this));
				this._get_node("*").bind("mousemove", $.proxy(function(e){
					this._get_node("#avatar-draggable, #avatar-mask").css("cursor", "se-resize");
					this.get_container().css("cursor", "se-resize");
					var rect = this._get_node("#avatar-draggable")[0].getBoundingClientRect();
					var x = e.pageX  - rect.left;
					var y = e.pageY  - rect.top; 
					if(x < y){
						this.data.core.dragDiv.setLen(x);
					}else{
						this.data.core.dragDiv.setLen(y);
					}
					if(this.data.core.dragDiv.len < 10) this.data.core.dragDiv.setLen(10);
					if(rect.top + this.data.core.dragDiv.len >= this.data.core.viewImg.top + this.data.core.viewImg.height || rect.left + this.data.core.dragDiv.len >= this.data.core.viewImg.left + this.data.core.viewImg.width){
						this._get_node("#avatar-controller").trigger("mouseup");
						return;
					}
					this._get_node("#avatar-draggable").css({"width" : this.data.core.dragDiv.width + "px", "height" : this.data.core.dragDiv.height + "px"});
					this.generateCss("block");
					this.generateAvatarCss(true);
				}, this));
			},
 			upload : function(){
 				var img = new Image();
				img.src = this.data.core.ctxBig.canvas.toDataURL("image/jpeg");
				img.onload = $.proxy(function(){
					this._get_node(".avatar-big-img div canvas").attr("width", 180).attr("height", 180);
					this.data.core.ctxBig.drawImage(img, 0, 0, img.width, img.height, 0, 0, 180, 180);
					/*this._get_node(".avatar-middle-img div canvas").attr("width", 50).attr("height", 50);
					this._get_node(".avatar-little-img div canvas").attr("width", 30).attr("height", 30);
					
					this.data.core.ctxMiddle.drawImage(img,  0, 0, img.width, img.height, 0, 0, 50, 50);
					this.data.core.ctxLittle.drawImage(img,  0, 0, img.width, img.height, 0, 0, 30, 30);*/
					var bigAvatar = new Image();
					bigAvatar.src = this.data.core.ctxBig.canvas.toDataURL("image/jpeg");
					this._get_node(".avatar-big-img span").text("实际上传图片大小" + (bigAvatar.src.length/1024/1.33).toFixed(1) + "K");
					if(bigAvatar.src.length > 204800) {
						alert("文件大于200K！");
						return;
					}
					
					var s = this.get_settings().ajax,
						error_func = function () {},
						success_func = function () {};
					
					if(!s.url) {
						alert("没有配置上传地址");
						return;
					}
					error_func = function(x, t, e){
						var ef = this.get_settings().ajax.error; 
						if(ef) { ef.call(this, x, t, e); } else { alert("上传失败！"); }
					}
					success_func = function (d, t, x) {
						var sf = this.get_settings().ajax.success; 
						if(sf) { sf.call(this,d,t,x); } else { alert("上传成功！"); }
					}
					s.context = this;
					s.data = "uploadAvatar=" + encodeURIComponent(bigAvatar.src.toString());
					s.error = error_func;
					s.success = success_func;
					s.type = "POST";
					$.ajax(s);
				}, this);
 			}
		}
	});
})(jQuery);