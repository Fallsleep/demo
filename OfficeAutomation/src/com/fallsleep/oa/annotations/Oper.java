package com.fallsleep.oa.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
/**
 * 用来定义操作的注解
 * @author fallsleep
 *
 */
@Retention(RetentionPolicy.RUNTIME)//运行时，可以进行反射获得注解当中的信息
@Target(ElementType.METHOD)//只能定义在方法
public @interface Oper {
	/**
	 * 操作的名称，允许不定义这个属性，自动根据方法的命名赋予一个值，规则如下：
	 * 	  add开头的方法自动给予一个名称：添加
	 *    update开头的方法，自动给予一个名称：更新
	 *    del开头，自动给予一个删除
	 *    其他方法，自动给予一个名称，查询
	 * @return
	 */
	String name() default "";
	/**
	 * 操作的唯一标识，如果不定义属性，自动根据方法名赋予一个默认值，规则如下：
	 *    add开头方法，自动给予一个标识：CREATE
	 *    update开头的方法，自动给予一个标识：UPDATE
	 *    del开头的方法，自动给予一个标识：DELETE
	 *    其他方法，自动给予一个标识：READ
	 * @return
	 */
	String sn() default "";
	/**
	 * 操作对应的索引，如果不定义属性，自动根据方法名赋予一个默认值，规则如下：
	 *    add开头方法，自动给予索引0
	 *    update开头的方法，自动给予索引1
	 *    del开头的方法，自动给予索引2
	 *    其他方法，自动给予一个索引3
	 * @return
	 */
	int index() default -1;
}
