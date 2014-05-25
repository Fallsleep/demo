package test.fallsleep;

import org.springframework.beans.factory.BeanFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import com.fallsleep.oa.service.InitService;

import junit.framework.TestCase;

public class Test extends TestCase {
	public void testInitService(){
		BeanFactory beanFactory = new ClassPathXmlApplicationContext("app*.xml");
		InitService initService = (InitService) beanFactory.getBean("initService");
		initService.addInitData();
	}

}
