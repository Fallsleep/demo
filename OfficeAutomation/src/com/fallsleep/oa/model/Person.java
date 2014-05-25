package com.fallsleep.oa.model;

public class Person extends Party {
	/**
	 * 职责
	 */
	private String duty;
	/**
	 * 性别
	 */
	private String sex;
	/**
	 * 手机
	 */
	private String phone;
	/**
	 * 员工编号
	 */
	private String snumber;
	/**
	 * QQ
	 */
	private String qq;
	/**
	 * MSN
	 */
	private String msn;
	/**
	 * 员工地址
	 */
	private String address;
	/**
	 * 邮件
	 */
	private String email;
	/**
	 * 账号
	 */
	private User user;
	
	public String getJob() {
		return duty;
	}

	public void setJob(String job) {
		this.duty = job;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getDuty() {
		return duty;
	}

	public void setDuty(String duty) {
		this.duty = duty;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getSnumber() {
		return snumber;
	}

	public void setSnumber(String snumber) {
		this.snumber = snumber;
	}

	public String getQq() {
		return qq;
	}

	public void setQq(String qq) {
		this.qq = qq;
	}

	public String getMsn() {
		return msn;
	}

	public void setMsn(String msn) {
		this.msn = msn;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

}
