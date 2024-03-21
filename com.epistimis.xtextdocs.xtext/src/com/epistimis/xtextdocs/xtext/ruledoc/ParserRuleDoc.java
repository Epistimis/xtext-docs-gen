/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
* Copyright (c) 2024 Epistimis LLC
* 
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.epistimis.xtextdocs.xtext.ruledoc;

import org.eclipse.xtext.AbstractElement;
import org.eclipse.xtext.ParserRule;

import com.epistimis.xtextdocs.xtext.doccomment.DocComment;
import com.google.common.base.Preconditions;

/**
 * Represents the documentation attached to a {@link ParserRule} Xtext rule.
 */
public class ParserRuleDoc extends ReferenceRuleDoc {
	private ParserRule rule;

	/**
	 * Creates a new documentation for the given parser rule with the given head
	 * comment.
	 * 
	 * @param rule
	 *            Represented rule. Shall not be {@code null}.
	 * @param headComment
	 *            Head comment attached to the represented rule. Shall not be
	 *            {@code null}.
	 */
	public ParserRuleDoc(ParserRule rule, DocComment headComment) {
		super(headComment);

		this.rule = Preconditions.checkNotNull(rule);
	}

	@Override
	public ParserRule getRule() {
		return rule;
	}

	/**
	 * Returns the definition of the Xtext rule.
	 * 
	 * @return Rule definition.
	 */
	public AbstractElement getAlternatives() {
		return rule.getAlternatives();
	}
}
