package com.fallsleep.oa.dao;

import java.util.List;

import com.fallsleep.oa.vo.PagerVO;

public interface BaseDao {
	public void save(Object entity);
	public void update(Object entity);
	public void del(Object entity);
	public <T> T findById(Class<T> entityClass, int id);
	public <T> List<T> findAll(Class<T> entityClass);
	/**
	 * 通用分页查询方法
	 * @param hql
	 * @param offset
	 * @param pagesize
	 * @param params
	 * @return
	 */
	public PagerVO findPaging(String hql, int offset, int pagesize, Object...params);
	public PagerVO findPaging(String hql, Object...params);
}
