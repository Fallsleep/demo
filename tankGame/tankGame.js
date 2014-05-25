//direct 0上 1左 2下 3右
var heroColors=new Array("#BA9658","#FEF26E");
var enemyColors=new Array("#00A2B5","#00FEFE");
//炸弹类
function Bomb(x,y){
	this.x=x;
	this.y=y;
	this.isLive=true;
	this.blood=9;
	this.bloodDown=function(){
		if(this.blood>0){
			this.blood--;
		}else{
			this.isLive=false;
		}
	}
}
//子弹类,index等于-1为敌人子弹
function Bullet(x,y,direct,speed,type,tank){
	this.x=x;
	this.y=y;
	this.speed=speed;
	this.direct=direct;
	this.timer=null;
	this.type=type;
	this.tank=tank;
	this.isLive=true;
	this.run=function(){
		if(this.x<=0||this.y<=0||this.x>=400||this.y>=300||this.isLive==false){
			window.clearInterval(this.timer);
			if(this.type=="enemy"){
				this.tank.bulletIsLive=false;
			}else{
				this.tank.bulletNum--;
			}
			this.isLive=false;
		}else{
			switch(this.direct){
			case 0://上
				this.y-=this.speed;
				break;
			case 1://左
				this.x-=this.speed;
				break;
			case 2://下
				this.y+=this.speed;
				break;
			case 3://右
				this.x+=this.speed;
				break;
			}
		}
	}
}
function Tank(x,y,direct,speed,colors){
	this.x=x;
	this.y=y;
	this.width=22;
	this.height=30;
	this.speed=speed;
	this.colors=colors;
	this.isLive=true;
	this.direct=direct;

	this.moveUp=function(){
		if(this.y>0){
			this.width=22;
			this.height=30;
			this.direct=0;
			if(!isUpTouch(this))
				this.y-=this.speed;
		}
	}
	this.moveLeft=function(){
		if(this.x>0){
			this.width=30;
			this.height=22;
			this.direct=1;
			if(!isLeftTouch(this))
				this.x-=this.speed;
		}
	}
	this.moveDown=function(){
		if(this.y+this.height<300){
			this.width=22;
			this.height=30;
			this.direct=2;
			if(!isDownTouch(this))
				this.y+=this.speed;
		}
	}
	this.moveRight=function(){
		if(this.x+this.width<400){
			this.width=30;
			this.height=22;
			this.direct=3;
			if(!isRightTouch(this))
				this.x+=this.speed;
		}
	}
}

//定义Hero类
function Hero(x,y,direct,speed,colors){
	this.tank=Tank;
	this.tank(x,y,direct,speed,colors);
	this.bulletNum=0;
	this.shot=function(){
		if(this.bulletNum<100){
			var x,y;
			switch(this.direct){
			case 0://上
				x=this.x+10;
				y=this.y-2;
				break;
			case 1://左
				x=this.x-2;
				y=this.y+10;
				break;
			case 2://下
				x=this.x+10;
				y=this.y+31;
				break;
			case 3://右
				x=this.x+31;
				y=this.y+10;
				break;
			}
			heroBullet=new Bullet(x,y,this.direct,2,"hero",this);
			heroBullets.push(heroBullet);
			var timer=window.setInterval("heroBullets["+(heroBullets.length-1)+"].run()",50);
			heroBullets[heroBullets.length-1].timer=timer;
			this.bulletNum++;
		}
	}
	
	//绘制自己子弹
	this.drawHeroBullet=function(){
		for(var i=0;i<heroBullets.length;i++){
			if(heroBullets[i]!=null&&heroBullets[i].isLive){
				cxt.fillStyle="#FEF26E";
				cxt.fillRect(heroBullets[i].x,heroBullets[i].y,2,2);
			}
		}
	}
}

//定义EnemyTank类
function EnemyTank(x,y,direct,speed,colors){
	this.tank=Tank;
	this.tank(x,y,direct,speed,colors);
	this.bulletIsLive=true;
	this.isLive=true;
	this.count=0;
	this.timer=null;
	this.run=function(){
		if(this.isLive){
			//坦克移动
			switch(this.direct){
			case 0://上
				this.moveUp();
				break;
			case 1://左
				this.moveLeft();
				break;
			case 2://下
				this.moveDown();
				break;
			case 3://右
				this.moveRight();
				break;
			}

			//走20-100步，改变方向
			if(this.count>20+Math.round(Math.random()*80)){
				this.direct=Math.round(Math.random()*3);//随机生成0,1,2,3
				this.count=0;
			}
			this.count++;
		}else{
			window.clearInterval(this.timer);
		}

		if(this.bulletIsLive==false){
			//生成子弹
			var x,y;
			switch(this.direct){
			case 0://上
				x=this.x+10;
				y=this.y-2;
				break;
			case 1://左
				x=this.x-2;
				y=this.y+10;
				break;
			case 2://下
				x=this.x+10;
				y=this.y+31;
				break;
			case 3://右
				x=this.x+31;
				y=this.y+10;
				break;
			}
			enemyBullet=new Bullet(x,y,this.direct,2,"enemy",this);
			enemyBullets.push(enemyBullet);
			var timer=window.setInterval("enemyBullets["+(enemyBullets.length-1)+"].run()",50);
			enemyBullets[enemyBullets.length-1].timer=timer;
			this.bulletIsLive=true;
		}
	}
	
	//绘制敌人子弹
	this.drawEnemyBullet=function(){
		for(var i=0;i<enemyBullets.length;i++){
			if(enemyBullets[i]!=null&&enemyBullets[i].isLive){
				cxt.fillStyle="#00FEFE";
				cxt.fillRect(enemyBullets[i].x,enemyBullets[i].y,2,2);
			}
		}
	}
}

//绘制坦克，tank为对象
function drawTank(tank){
	if(tank.isLive){
		switch(tank.direct){
		case 0://上
		case 2://下
			cxt.fillStyle=tank.colors[0];
			cxt.fillRect(tank.x,tank.y,5,30);
			cxt.fillRect(tank.x+17,tank.y,5,30);
			cxt.fillRect(tank.x+6,tank.y+5,10,20);
			
			cxt.fillStyle=tank.colors[1];
			cxt.beginPath();
			cxt.arc(tank.x+11,tank.y+15,5,0,Math.PI*2,true);
			cxt.closePath();
			cxt.fill();

			cxt.strokeStyle=tank.colors[1];
			cxt.lineWidth=1.5;
			cxt.beginPath();
			if(tank.direct==0)
				cxt.moveTo(tank.x+11,tank.y);
			else if(tank.direct==2)
				cxt.moveTo(tank.x+11,tank.y+30);
			cxt.lineTo(tank.x+11,tank.y+15);
			cxt.closePath();
			cxt.stroke();
			break;
		case 1://左
		case 3://右
			cxt.fillStyle=tank.colors[0];
			cxt.fillRect(tank.x,tank.y,30,5);
			cxt.fillRect(tank.x,tank.y+17,30,5);
			cxt.fillRect(tank.x+5,tank.y+6,20,10);
			
			cxt.fillStyle=tank.colors[1];
			cxt.beginPath();
			cxt.arc(tank.x+15,tank.y+11,5,0,Math.PI*2,true);
			cxt.closePath();
			cxt.fill();

			cxt.strokeStyle=tank.colors[1];
			cxt.lineWidth=1.5;
			cxt.beginPath();
			if(tank.direct==1)
				cxt.moveTo(tank.x,tank.y+11);
			else if(tank.direct==3)
				cxt.moveTo(tank.x+30,tank.y+11);
			cxt.lineTo(tank.x+15,tank.y+11);
			cxt.closePath();
			cxt.stroke();
			break;
		}
	}
}
//坦克是否上碰撞
function isUpTouch(tank){
	if(tank==hero){
		for(var i=0;i<enemyTanks.length;i++){
			var enemyTank=enemyTanks[i];
			if(tank.y==enemyTank.y+enemyTank.height
				&&tank.x+tank.width>enemyTank.x
				&&tank.x<enemyTank.x+enemyTank.width
				&&enemyTank.isLive){
				return true;
			}
		}
		return false;
	}
	if(tank.y==hero.y+hero.height
		&&tank.x+tank.width>hero.x
		&&tank.x>hero.x+hero.width
		&&hero.isLive){
		return true;
	}
	for(var i=0;i<enemyTanks.length;i++){
		var enemyTank=enemyTanks[i];
		if(tank!=enemyTank){
			if(tank.y==enemyTank.y+enemyTank.height
				&&tank.x+tank.width>enemyTank.x
				&&tank.x<enemyTank.x+enemyTank.width
				&&enemyTank.isLive){
				return true;
			}
		}
	}
	return false;
}
//坦克是否左碰撞
function isLeftTouch(tank){
	if(tank==hero){
		for(var i=0;i<enemyTanks.length;i++){
			var enemyTank=enemyTanks[i];
			if(tank.x==enemyTank.x+enemyTank.width
				&&tank.y+tank.height>enemyTank.y
				&&tank.y<enemyTank.y+enemyTank.height
				&&enemyTank.isLive){
				return true;
			}
		}
		return false;
	}
	if(tank.x==hero.x+hero.width
		&&tank.y+tank.height>hero.y
		&&tank.y<hero.y+hero.height
		&&hero.isLive){
		return true;
	}
	for(var i=0;i<enemyTanks.length;i++){
		var enemyTank=enemyTanks[i];
		if(tank!=enemyTank){
			if(tank.x==enemyTank.x+enemyTank.width
				&&tank.y+tank.height>enemyTank.y
				&&tank.y<enemyTank.y+enemyTank.height
				&&enemyTank.isLive){
				return true;
			}
		}
	}
	return false;
}
//坦克是否下碰撞
function isDownTouch(tank){
	if(tank==hero){
		for(var i=0;i<enemyTanks.length;i++){
			var enemyTank=enemyTanks[i];
			if(tank.y+tank.height==enemyTank.y
				&&tank.x+tank.width>enemyTank.x
				&&tank.x<enemyTank.x+enemyTank.width
				&&enemyTank.isLive){
				return true;
			}
		}
		return false;
	}
	if(tank.y+tank.height==hero.y
		&&tank.x+tank.width>hero.x
		&&tank.x<hero.x+hero.width
		&&hero.isLive){
		return true;
	}
	for(var i=0;i<enemyTanks.length;i++){
		var enemyTank=enemyTanks[i];
		if(tank!=enemyTank){
			if(tank.y+tank.height==enemyTank.y
				&&tank.x+tank.width>enemyTank.x
				&&tank.x<enemyTank.x+enemyTank.width
				&&enemyTank.isLive){
				return true;
			}
		}
	}
	return false;
}
//坦克是否右碰撞
function isRightTouch(tank){
	if(tank==hero){
		for(var i=0;i<enemyTanks.length;i++){
			var enemyTank=enemyTanks[i];
			if(tank.x+tank.width==enemyTank.x
				&&tank.y+tank.height>enemyTank.y
				&&tank.y<enemyTank.y+enemyTank.height
				&&enemyTank.isLive){
				return true;
			}
		}
		return false;
	}
	if(tank.x+tank.width==hero.x
		&&tank.y+tank.height>hero.y
		&&tank.y<hero.y+hero.height
		&&hero.isLive){
		return true;
	}
	for(var i=0;i<enemyTanks.length;i++){
		var enemyTank=enemyTanks[i];
		if(tank!=enemyTank){
			if(tank.x+tank.width==enemyTank.x
				&&tank.y+tank.height>enemyTank.y
				&&tank.y<enemyTank.y+enemyTank.height
				&&enemyTank.isLive){
				return true;
			}
		}
	}
	return false;
}
//子弹是否击中敌人
function isHitEnemyTank(){
	for(var i=0;i<heroBullets.length;i++){
		var heroBullet=heroBullets[i];
		if(heroBullet.isLive){
			for(var j=0;j<enemyTanks.length;j++){
				var enemyTank=enemyTanks[j];
				if(enemyTank.isLive){
					if(enemyTank.x<=heroBullet.x&&enemyTank.x+enemyTank.width>=heroBullet.x
						&&enemyTank.y<=heroBullet.y&&enemyTank.y+enemyTank.height>=heroBullet.y){
						enemyTank.isLive=false;
						heroBullet.isLive=false;
						enemyTankNum--;
						var bomb=new Bomb(enemyTank.x,enemyTank.y);
						bombs.push(bomb);
					}
				}
			}
		}
	}
}
//自己是否被击中
function isEnemyTankHitHero(){
	for(var i=0;i<enemyBullets.length;i++){
		var enemyBullet=enemyBullets[i];
		if(enemyBullet.isLive){
			if(hero.x<=enemyBullet.x&&hero.x+hero.width>=enemyBullet.x
				&&hero.y<=enemyBullet.y&&hero.y+hero.height>=enemyBullet.y){
				hero.isLive=false;
				enemyBullet.isLive=false;
				return true;
			}
		}
	}
	return false;
}

function drawBomb(){
	for(var i=0;i<bombs.length;i++){
		var bomb=bombs[i];
		if(bomb.isLive){
			var x=bomb.x;
			var y=bomb.y;
			if(bomb.blood>6){
				var img1=new Image();
				img1.src="bomb_1.gif";
				img1.onload=function(){
					cxt.drawImage(img1,x,y,30,30);
				}
			}else if(bomb.blood>3){
				img2=new Image();
				img2.src="bomb_2.gif";
				img2.onload=function(){
					cxt.drawImage(img2,x,y,30,30);
				}
			}else{
				img3=new Image();
				img3.src="bomb_3.gif";
				img3.onload=function(){
					cxt.drawImage(img3,x,y,30,30);
				}
			}
		}
		bomb.bloodDown();
		if(bomb.blood<=0){
			bombs.splice(i,1);
		}
	}
}