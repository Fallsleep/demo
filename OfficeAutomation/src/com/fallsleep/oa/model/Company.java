package com.fallsleep.oa.model;

public class Company extends Party {
	/**
	 * 公司电话
	 */
	private String tel;
	/**
	 * 公司传真
	 */
	private String fax;
	/**
	 * 公司地址
	 */
	private String address;
	/**
	 * 公司邮编
	 */
	private String postcode;
	/**
	 * 公司网站
	 */
	private String site;
	/**
	 * 公司邮件
	 */
	private String email;
	/**
	 * 公司所属行业
	 */
	private String industry;

	public String getTel() {
		return tel;
	}

	public void setTel(String tel) {
		this.tel = tel;
	}

	public String getFax() {
		return fax;
	}

	public void setFax(String fax) {
		this.fax = fax;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getPostcode() {
		return postcode;
	}

	public void setPostcode(String postcode) {
		this.postcode = postcode;
	}

	public String getSite() {
		return site;
	}

	public void setSite(String site) {
		this.site = site;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getIndustry() {
		return industry;
	}

	public void setIndustry(String industry) {
		this.industry = industry;
	}
}
