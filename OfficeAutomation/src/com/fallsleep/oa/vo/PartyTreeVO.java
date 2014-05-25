package com.fallsleep.oa.vo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.fallsleep.oa.model.Party;

public class PartyTreeVO {
	private Map data = new HashMap();
	private Map attr = new HashMap();
	private List<PartyTreeVO> children = null;
	
	public PartyTreeVO(Party party) {
		this.data.put("title", party.getName());
		this.attr.put("id", party.getId());
		/**
		 * partyType must be one of the following value:
		 * 	company
		 *  department
		 *  position
		 *  person
		 */
		this.attr.put("partyType", party.getClass().getSimpleName().toLowerCase());
		
		Set<Party> children = party.getChildren();
		if(children != null && children.size() > 0){
			this.children = new ArrayList<PartyTreeVO>();
			for (Party p : children) {
				this.children.add(new PartyTreeVO(p));
			}
		}
	}
	public Map getData() {
		return data;
	}
	public void setData(Map data) {
		this.data = data;
	}
	public Map getAttr() {
		return attr;
	}
	public void setAttr(Map attr) {
		this.attr = attr;
	}
	public List<PartyTreeVO> getChildren() {
		return children;
	}
	public void setChildren(List<PartyTreeVO> children) {
		this.children = children;
	}
		
}
