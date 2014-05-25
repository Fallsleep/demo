package com.fallsleep.oa.service.impl;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.core.type.AnnotationMetadata;
import org.springframework.core.type.ClassMetadata;
import org.springframework.core.type.MethodMetadata;
import org.springframework.core.type.classreading.CachingMetadataReaderFactory;
import org.springframework.core.type.classreading.MetadataReader;
import org.springframework.core.type.classreading.MetadataReaderFactory;
import org.springframework.stereotype.Service;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.dao.ResourceDao;
import com.fallsleep.oa.model.ActionMethodOper;
import com.fallsleep.oa.model.ActionResource;
import com.fallsleep.oa.service.ResourceService;
@Service("resourceService")
public class ResourceServiceImpl implements ResourceService {
	Logger logger = Logger.getLogger(ResourceServiceImpl.class);
	@Resource
	private ResourceDao resourceDao;
	@Override
	public void rebuildActionResource() {
		try {
			// 扫描某个包，把其中的Action类扫描出来
			String pathPattern = "com/fallsleep/oa/web/**/*Action.class";
			//创建spring的路径模式解释器
			ResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
			//把路径下所有的符合路径模式的类的元数据封装成Resource类
			org.springframework.core.io.Resource[] res = resolver.getResources(pathPattern);
			if(res != null){
				//创建元数据读取工厂
				MetadataReaderFactory metadataReaderFactory = new CachingMetadataReaderFactory();
				//扫描每个Resource
				for (org.springframework.core.io.Resource r : res) {
					//得到读取指定类信息的MetadataReader
					MetadataReader metadataReader = metadataReaderFactory.getMetadataReader(r);
					//提取信息，保存ActionResource对象
					saveActionResource(metadataReader, metadataReaderFactory, resolver);
				}
				//建立ActionResource父子关系
				List<ActionResource> resources = resourceDao.findAll();
				for (ActionResource ar : resources) {
					String parentSn = ar.getParentSn();
					if(parentSn != null && !"".equals(parentSn)){
						ActionResource parent = resourceDao.findActionResourceBySn(parentSn);
						if(parent != null){
							ar.setParent(parent);
						}
					}
				}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		

	}
	
	private void saveActionResource(MetadataReader metadataReader,
			MetadataReaderFactory metadataReaderFactory,
			ResourcePatternResolver resolver) throws IOException {
		// 得到类的元数据
		ClassMetadata classMetadata = metadataReader.getClassMetadata();
		//得到注解的元数据
		AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
		//判断类是否定义@Res注解
		if(annotationMetadata.hasAnnotation(Res.class.getName())){
			logger.debug("扫描到类["+ classMetadata.getClassName() +"]包含Res注解");
			/*******************提取资源信息********************/
			//取出@Res注解的属性
			Map resAttrs = annotationMetadata.getAnnotationAttributes(Res.class.getName());
			
			//获取@Res注解中name属性
			String name = (String) resAttrs.get("name");
			//获取@Res注解中sn属性
			String sn = (String) resAttrs.get("sn");
			//获取@Res注解中orderNumber属性
			int orderNumber = (Integer) resAttrs.get("orderNumber");
			//获取@Res注解中parentSn属性
			String parentSn = (String) resAttrs.get("parentSn");
			//获取@Res所在类的类名
			String className = classMetadata.getClassName();
			
			/*******************根据这些信息可以创建ActionResource对象********************/
			ActionResource actionResource = resourceDao.findActionResourceBySn(sn);
			if(actionResource == null){
				actionResource = new ActionResource();
			}
			actionResource.addClassName(className);
			actionResource.setName(name);
			actionResource.setSn(sn);
			actionResource.setOrderNumber(orderNumber);
			actionResource.setParentSn(parentSn);
			
			logger.debug("扫描到资源[" + sn + "(" + name + ")];");
			
			//搜索本类型下面定义了@Oper的方法及其父类下面定义@Oper的方法
			searchOperAnnotations(actionResource, metadataReader, metadataReaderFactory, resolver);
			
			resourceDao.save(actionResource);
		}
	}
	
	private void searchOperAnnotations(ActionResource actionResource,
			MetadataReader metadataReader,
			MetadataReaderFactory metadataReaderFactory,
			ResourcePatternResolver resolver) throws IOException {
		// 得到注解元数据
		AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
		//扫描类下面定义@Oper的方法
		Set<MethodMetadata> mms = annotationMetadata.getAnnotatedMethods(Oper.class.getName());
		if(mms != null){
			for (MethodMetadata m : mms) {
				Map<String, Object> operAttrs = m.getAnnotationAttributes(Oper.class.getName());
				String methodName = m.getMethodName();
				String operName = (String) operAttrs.get("name");
				if(operName == null || "".equals(operName)){
					operName = getDefaultOperName(methodName);
				}
				String operSn = (String) operAttrs.get("sn");
				if(operSn == null || "".equals(operSn)){
					operSn = getDefaultOperSn(methodName);
				}
				int operIndex = (Integer) operAttrs.get("index");
				if(operIndex == -1){
					operIndex = getDefaultOperIndex(methodName);
				}
				actionResource.addActionMethodOper(methodName, operName, operSn, operIndex);
				logger.debug("扫描到操作[" + operSn + "(" + operName + ")][" + operIndex + "]:" + methodName);
			}
		}
		//如果有父类，而且不是java.lang.Object，则继续搜索父类当中是否还包含@Oper注解的方法
		if(metadataReader.getClassMetadata().hasSuperClass() &&
				!metadataReader.getClassMetadata().getSuperClassName().equals(Object.class.getName())){
			//得到父类名称
			String superClassName = metadataReader.getClassMetadata().getSuperClassName();
			//构造父类资源路径
			String superClassPath = superClassName.replace('.', '/') + ".class";
			org.springframework.core.io.Resource superClassResource = resolver.getResource(superClassPath);
			searchOperAnnotations(actionResource, metadataReaderFactory.getMetadataReader(superClassResource),
					metadataReaderFactory, resolver);
		}
	}

	private int getDefaultOperIndex(String methodName) {
		if(methodName.startsWith("add")){
			return 0;
		}else if(methodName.startsWith("update")){
			return 1;
		}else if(methodName.startsWith("del")){
			return 2;
		}
		return 3;
	}

	private String getDefaultOperSn(String methodName) {
		if(methodName.startsWith("add")){
			return "CREATE";
		}else if(methodName.startsWith("update")){
			return "UPDATE";
		}else if(methodName.startsWith("del")){
			return "DELETE";
		}
		return "READ";
	}

	private String getDefaultOperName(String methodName) {
		if(methodName.startsWith("add")){
			return "添加";
		}else if(methodName.startsWith("update")){
			return "更新";
		}else if(methodName.startsWith("del")){
			return "删除";
		}
		return "查询";
	}

	@Override
	public List<ActionResource> findAllTopActionResources() {
		return resourceDao.findAllTopActionResources();
	}

	@Override
	public void addActionResource(ActionResource actionResource) {
		resourceDao.save(actionResource);
	}

	@Override
	public ActionResource findById(int id) {
		return resourceDao.findById(ActionResource.class, id);
	}

	@Override
	public void updateActionResource(ActionResource actionResource) {
		resourceDao.update(actionResource);
	}

	@Override
	public void delActionResource(int id) {
		resourceDao.del(findById(id));
	}

	@Override
	public void addActionResourceOper(int id, ActionMethodOper oper) {
		ActionResource ar = resourceDao.findById(ActionResource.class, id);
		ar.addActionMethodOper(oper.getMethodName(), oper.getOperName(), oper.getOperSn(), oper.getOperIndex());
	}

	@Override
	public void delActionResourceOper(int id, String operSn) {
		ActionResource ar = resourceDao.findById(ActionResource.class, id);
		ar.removeActionMethodOper(operSn);
	}

	@Override
	public List<ActionResource> findAllActionResources() {
		return resourceDao.findAll();
	}

	@Override
	public ActionResource findActionResourceByClassName(String className) {
		return resourceDao.findActionResourceByClassName(className);
	}

}
