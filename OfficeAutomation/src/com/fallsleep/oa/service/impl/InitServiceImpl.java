package com.fallsleep.oa.service.impl;

import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;

import com.fallsleep.oa.dao.InitDao;
import com.fallsleep.oa.service.InitService;
import com.fallsleep.oa.service.ResourceService;

public class InitServiceImpl implements InitService, BeanFactoryAware{
	@Resource
	private InitDao initDao;
	private String path;
	private BeanFactory beanFactory= null;
	public void setPath(String path) {
		this.path = path;
	}

	@Override
	public void addInitData() {
		try {
			//解析XML文件
			Document document = new SAXReader().read(Thread.currentThread().
					getContextClassLoader().getResourceAsStream(path));
			//得到根元素
			Element root = document.getRootElement();
			//得到包名
			String pkg = root.valueOf("@package");
			//得到根元素下entity的集合
			List<Element> entities = root.selectNodes("entity");
			
			for (Iterator<Element> iterator = entities.iterator(); iterator.hasNext();) {
				Element e = iterator.next();
				addEntity(e, pkg, null, null);
			}
			
			//重建所有ActionResource资源
			ResourceService resourceService = (ResourceService) beanFactory.getBean("resourceService");
			resourceService.rebuildActionResource();
			
			//初始化超级管理员
			initDao.addInitAdmin();
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void addEntity(Element e, String pkg, Object parent, String callString) {
		try {
			// 处理Element
			//1、要创建什么类型的对象
			String className = pkg + "." + e.attributeValue("class");
			Object entity = Class.forName(className).newInstance();
			Iterator iterator = e.attributeIterator();
			while(iterator.hasNext()){
				Attribute attr = (Attribute)iterator.next();
				String propName = attr.getName();
				if(!"class".equals(propName) && !"call".equals(propName)){
					String propValue = attr.getValue();
					BeanUtils.copyProperty(entity, propName, propValue);
				}
			}
			BeanUtils.copyProperty(entity, "parent", parent);
			
			//2、存储（调用哪个service）
			String call = e.attributeValue("call");
			if(call != null){
				callString = call;
			}
			if(callString == null){
				throw new RuntimeException("unknown call mehtod,can't create entity!");
			}
			
			//3、调用相应的方法存储实体
			String[] msg = callString.split("\\.");
			String serviceName = msg[0];
			String methodName = msg[1];
			//得到Service对象
			Object serviceObject = beanFactory.getBean(serviceName);
			//得到要调用Service对象上的方法的反射类
			for(Method method : serviceObject.getClass().getMethods()){
				if(methodName.equals(method.getName())){
					//调用这个方法
					method.invoke(serviceObject, entity);
				}
			}
			
			//4、考虑当前Element有没有子元素
			List<Element> subEntities = e.elements("entity");
			for(Iterator<Element> iter = subEntities.iterator(); iter.hasNext();){
				Element subElement = iter.next();
				addEntity(subElement, pkg, entity, callString);
			}
		} catch (Exception e1) {
			e1.printStackTrace();
		} 
	}

	@Override
	public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
		this.beanFactory = beanFactory;
	}

}
