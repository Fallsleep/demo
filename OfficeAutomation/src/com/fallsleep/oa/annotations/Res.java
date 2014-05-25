package com.fallsleep.oa.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
/**
 * 用来定义资源的注解
 * @author fallsleep
 *
 */
@Retention(RetentionPolicy.RUNTIME)//运行时，可以进行反射获得注解当中的信息
@Target(ElementType.TYPE)//只能定义在类前
public @interface Res {
	/**
	 * 资源名称，必须定义
	 * @return
	 */
	String name();
	/**
	 * 资源唯一标识，必须定义
	 * @return
	 */
	String sn();
	/**
	 * 资源的排序号
	 * @return
	 */
	int orderNumber() default 0;
	/**
	 * 父资源的标识
	 * @return
	 */
	String parentSn() default "";
}
