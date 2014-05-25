package test.fallsleep;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.jbpm.api.ExecutionService;
import org.jbpm.api.ProcessEngine;
import org.jbpm.api.ProcessInstance;
import org.jbpm.api.RepositoryService;
import org.jbpm.api.TaskService;
import org.jbpm.api.model.Activity;
import org.jbpm.api.model.Transition;
import org.jbpm.api.task.Task;
import org.jbpm.pvm.internal.env.EnvironmentFactory;
import org.jbpm.pvm.internal.env.EnvironmentImpl;
import org.jbpm.pvm.internal.model.ExecutionImpl;
import org.jbpm.pvm.internal.model.ProcessDefinitionImpl;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.core.type.AnnotationMetadata;
import org.springframework.core.type.ClassMetadata;
import org.springframework.core.type.MethodMetadata;
import org.springframework.core.type.classreading.CachingMetadataReaderFactory;
import org.springframework.core.type.classreading.MetadataReader;
import org.springframework.core.type.classreading.MetadataReaderFactory;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.jsontools.Node;
import com.fallsleep.oa.model.Department;
import com.fallsleep.oa.model.Party;
import com.fallsleep.oa.model.Person;
import com.fallsleep.oa.service.InitService;
import com.fallsleep.oa.service.PartyService;
import com.sdicons.json.mapper.JSONMapper;
import com.sdicons.json.mapper.MapperException;

import junit.framework.TestCase;

public class Test extends TestCase {
	public void test() throws MapperException{
		Map attr = new HashMap();
		attr.put("id", 1);
		Map data = new HashMap();
		data.put("title", "秋意无眠科技有限公司");
		Node root = new Node(data, attr);
		Map data1 = new HashMap();
		data1.put("title", "培训1部");
		root.addChildNode(new Node(data1, 2));
		Map data2 = new HashMap();
		data2.put("title", "培训2部");
		Map data3 = new HashMap();
		data3.put("title", "培训2-1部");
		Node child2 = new Node(data2, 3);
		child2.addChildNode(new Node(data3, 4));
		Map data4 = new HashMap();
		data4.put("title", "培训2-2部");
		child2.addChildNode(new Node(data4, 5));
		root.addChildNode(child2);
		String string = JSONMapper.toJSON(root).render(true);
		System.out.println(string);
	}
	public void add(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		PartyService partyService = (PartyService) beanFactory.getBean("partyService");
		Party company = partyService.findById(1);
		
		//创建一系列部门 
		for(int i = 0 ; i < 10 ; i++){
			Department d = new Department();
			d.setName("部门" + i);
			d.setParent(company);
			partyService.addParty(d);
			
			for(int j = 0 ; j < 5 ; j++){
				Person p = new Person();
				p.setName(d.getName() + "下的人员" + j);
				p.setParent(d);
				partyService.addParty(p);
			}
		}

	}
	
	public void testInitService(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		InitService initService = (InitService) beanFactory.getBean("initService");
		initService.addInitData();
	}
	
	public void testSpringResource(){
		try {
			//获取资源解释器
			String path = "com/fallsleep/oa/**/*Action.class";
			ResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
			Resource[] res = resolver.getResources(path);
			
			//要读取资源对象，必须使用spring提供的MetadateReader对象
			MetadataReaderFactory metaFactory = new CachingMetadataReaderFactory();
			MetadataReader metadataReader = metaFactory.getMetadataReader(res[0]);
			
			ClassMetadata classMetadata = metadataReader.getClassMetadata();
			
			AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
			System.out.println(classMetadata.getClassName());
			
			Map resAttrs = annotationMetadata.getAnnotationAttributes(Res.class.getName());
			System.out.println(resAttrs.get("name"));
			
			Set<MethodMetadata> methods = annotationMetadata.getAnnotatedMethods(Oper.class.getName());
			for (MethodMetadata methodMetadata : methods) {
				System.out.println(methodMetadata.getMethodName());
				System.out.println(methodMetadata.getAnnotationAttributes(Oper.class.getName()).get("name"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void testFile(){
		File folder = new File("D:/1/");
		if(!folder.isDirectory()){
			System.out.println(folder);
			folder.mkdir();
			File f = new File(folder + "1.txt");
			try {
				System.out.println(f.getName());
				System.out.println(f);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	
	public void testJbpm(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		RepositoryService repositoryService = (RepositoryService) beanFactory.getBean("repositoryService");
		if(repositoryService != null){
			String id = repositoryService.createDeployment().addResourceFromClasspath("test/fallsleep/test.jpdl.xml").deploy();
			System.out.println("部署完成:" + id);
			String name = repositoryService.createProcessDefinitionQuery().deploymentId(id).uniqueResult().getName();
			System.out.println("部署完成:" + name);
		}
	}
	
	public void testJbpmCreate(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		ExecutionService executionService = (ExecutionService) beanFactory.getBean("executionService");
		if(executionService != null){
			Map<String, String> map = new HashMap<String, String>();
			map.put("node", "2天以内");
			ProcessInstance processInstance = executionService.startProcessInstanceByKey("test", map);
			System.out.println("流程ID：" + processInstance.getId());
		}
	}
	public void testJbpmGetCurrentActivity(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		ProcessEngine processEngine =  (ProcessEngine) beanFactory.getBean("processEngine");
		ExecutionService executionService = (ExecutionService) beanFactory.getBean("executionService");
		RepositoryService repositoryService = (RepositoryService) beanFactory.getBean("repositoryService");
		if(executionService != null){
			ProcessInstance processInstance = executionService.createProcessInstanceQuery()
					.processInstanceId("test.120001").uniqueResult();
			System.out.println("当前节点：" + processInstance.findActiveActivityNames().toString()+"=====================");
			//获取所有节点信息
			ProcessDefinitionImpl processDefinitionImpl = (ProcessDefinitionImpl) repositoryService.createProcessDefinitionQuery().processDefinitionId(processInstance.getProcessDefinitionId()).uniqueResult();
			List<? extends Activity> list = processDefinitionImpl.getActivities();
			for(Activity activity : list){
				List<? extends Transition> tsList = activity.getOutgoingTransitions();
				for (Transition ts : tsList) {
					System.out.println("当前节点：" + activity.getName() + "    将要：" + (ts != null?ts.getName():"无"));
				}
			}
		}
	}
	public void testJbpmGetTask(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		TaskService taskService = (TaskService) beanFactory.getBean("taskService");
		if(taskService != null){
			List<Task> tasks = taskService.findPersonalTasks("张三");
			System.out.println("任务名称：" + tasks.get(0).getActivityName());
			System.out.println("审批人员：" + tasks.get(0).getAssignee());
			System.out.println("任务ID：" + tasks.get(0).getId());
			System.out.println("ExecutionId：" + tasks.get(0).getExecutionId());
		}
	}
	public void testJbpmCompleteTask(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		TaskService taskService = (TaskService) beanFactory.getBean("taskService");
		if(taskService != null){
			taskService.completeTask("10002");
			System.out.println("任务完成");
		}
	}
}
