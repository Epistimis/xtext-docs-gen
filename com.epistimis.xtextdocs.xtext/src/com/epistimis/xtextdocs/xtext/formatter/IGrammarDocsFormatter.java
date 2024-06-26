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

package com.epistimis.xtextdocs.xtext.formatter;

import java.util.Map;

import org.eclipse.xtext.AbstractRule;

import com.epistimis.xtextdocs.xtext.ruledoc.RuleDoc;
import com.epistimis.xtextdocs.xtext.ruledoc.GrammarDoc;

/**
 * Interface for grammar documentation generators. A class implementing this
 * interface should be capable of transforming a grammar documentation metamodel
 * ({@link GrammarDoc}) into a textual format.
 */
public interface IGrammarDocsFormatter {
	/**
	 * Returns a formatted, textual representation of the given grammar
	 * documentation node, including the rules contained within.
	 * 
	 * @param grammarDoc
	 *            Grammar documentation.
	 * @return Formatted, textual representation of the grammar.
	 */
	CharSequence formatGrammar(GrammarDoc grammarDoc);

	/**
	 * Returns a DOT graph textual representation of the given grammar
	 * documentation node, including the rules contained within.
	 * 
	 * @param grammarDoc
	 *            Grammar documentation.
	 * @return DOT graph textual representation of the grammar.
	 */
	CharSequence formatGraph(GrammarDoc grammarDoc);

	/**
	 * Returns a formatted, textual representation of the given single rule
	 * documentation node.
	 * 
	 * @param ruleDoc
	 *            Rule documentation.
	 * @param mapping
	 *            Mapping between Xtext's {@link AbstractRule}s and their
	 *            documentation equivalents. This can be used to represent the
	 *            dependencies between the rules.
	 * @return Formatted, textual representation of the rule.
	 */
	CharSequence formatRule(RuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping);
	
	/**
	 * Returns the file extension for the output files created by this formatter.
	 * @return The file extension
	 */
	String outputFileExtension();
}
