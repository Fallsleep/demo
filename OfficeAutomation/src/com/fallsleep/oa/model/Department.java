﻿package com.fallsleep.oa.model;

public class Department extends Party {
	/**
	 * 部门电话
	 */
	private String tel;
	/**
	 * 部门编号
	 */
	private String snumber;
	public String getTel() {
		return tel;
	}
	public void setTel(String tel) {
		this.tel = tel;
	}
	public String getSnumber() {
		return snumber;
	}
	public void setSnumber(String snumber) {
		this.snumber = snumber;
	}
}
