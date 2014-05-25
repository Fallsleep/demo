package com.fallsleep.oa.dao;

import com.fallsleep.oa.vo.PagerVO;

public interface RoleDao extends BaseDao {

	PagerVO findAllRoles(String sSearch, String sOrder);

}
