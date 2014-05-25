package com.fallsleep.oa.dao.impl;

import java.util.List;

import javax.annotation.Resource;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;

import com.fallsleep.oa.SystemContext;
import com.fallsleep.oa.dao.BaseDao;
import com.fallsleep.oa.vo.PagerVO;

public class BaseDaoImpl implements BaseDao{
	@Resource
	private SessionFactory sessionFactory;
	protected Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	@Override
	public void save(Object entity){
		getSession().save(entity);
	}
	@Override
	public void update(Object entity) {
		getSession().update(entity);
	}
	@Override
	public void del(Object entity) {
		getSession().delete(entity);
	}
	@Override
	public <T> T findById(Class<T> entityClass, int id) {
		return (T)getSession().load(entityClass, id);
	}
	@Override
	public <T> List<T> findAll(Class<T> entityClass) {
		return (List<T>)getSession().createCriteria(entityClass).list();
	}
	@Override
	public PagerVO findPaging(String hql, int offset, int pagesize,
			Object... params) {
		String countHql = getCountHql(hql);
		Query query = getSession().createQuery(countHql);
		if(params != null){
			for(int i = 0; i < params.length; ++i){
				query.setParameter(i, params[i]);
			}
		}
		long total = (Long)query.uniqueResult();
		query = getSession().createQuery(hql);
		if(params != null){
			for(int i = 0; i < params.length; ++i){
				query.setParameter(i, params[i]);
			}
		}
		query.setFirstResult(offset);
		query.setMaxResults(pagesize);
		List datas = query.list();
		PagerVO pageVO = new PagerVO();
		pageVO.setTotal((int) total);
		pageVO.setDatas(datas);
		return pageVO;
	}
	/**
	 * return the hql statement which querying the count of records according the given hql statement
	 * @param hql
	 * @return
	 */
	private String getCountHql(String hql){
		int index = hql.indexOf("from");
		if(index == -1){
			throw new RuntimeException("There's no 'from' in the hql statement!");
		}
		return "select count(*) " + hql.substring(index);
	}
	@Override
	public PagerVO findPaging(String hql, Object... params) {
		return findPaging(hql, SystemContext.getOffset(), SystemContext.getPagesize(), params);
	}
}
