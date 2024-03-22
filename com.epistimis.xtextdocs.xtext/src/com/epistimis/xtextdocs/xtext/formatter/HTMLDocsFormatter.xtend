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

package com.epistimis.xtextdocs.xtext.formatter

import com.epistimis.xtextdocs.common.formatter.DocCommentTextUtil
import com.epistimis.xtextdocs.common.formatter.MarkdownTextFormatter
import com.epistimis.xtextdocs.common.xtext.XtextTokenUtil
import com.epistimis.xtextdocs.xtext.doccomment.DocComment
import com.epistimis.xtextdocs.xtext.ruledoc.EnumRuleDoc
import com.epistimis.xtextdocs.xtext.ruledoc.EnumRuleDoc.EnumLiteralDoc
import com.epistimis.xtextdocs.xtext.ruledoc.GrammarDoc
import com.epistimis.xtextdocs.xtext.ruledoc.ParserRuleDoc
import com.epistimis.xtextdocs.xtext.ruledoc.ReferenceRuleDoc
import com.epistimis.xtextdocs.xtext.ruledoc.RuleDoc
import com.epistimis.xtextdocs.xtext.ruledoc.TerminalRuleDoc
import com.google.common.base.Preconditions
import com.google.common.base.Strings
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.xtext.AbstractElement
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.Action
import org.eclipse.xtext.Alternatives
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.CharacterRange
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.EnumLiteralDeclaration
import org.eclipse.xtext.Group
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.NegatedToken
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.UnorderedGroup
import org.eclipse.xtext.UntilToken
import org.eclipse.xtext.Wildcard
import com.epistimis.xtextdocs.common.formatter.HTMLTextFormatter

class HTMLDocsFormatter extends DotGraphBaseFormatter {

	static val extension HTMLTextFormatter textFormatter = HTMLTextFormatter.INSTANCE;

	override outputFileExtension() {
		return ".html";
	}

	/**
	 * Generates a table of contents representation based on the stored anchors.
	 * For now, we only create a ToC of the Parser Rules - they are the key ones. 
	 */
	private def toc(GrammarDoc grammarDoc) {
		return '''
			<div class="toc" id="toc">
			<h2> Table of contents</h2>
			«val tocContents = grammarDoc.rules.filter(ParserRuleDoc).toSet.sortBy[it.ruleName]»
			<ul>
			«FOR ruleDoc : tocContents»
				<li>«link(ruleDoc.getRuleName(), toAnchor(ruleDoc.getRuleName()).toLowerCase())»</li>
			«ENDFOR»
			</ul>
			</div>
		''';
	}

	/**
	 * Returns a Markdown-formatted document describing the given grammar,
	 * including all its rules.
	 * <p>
	 * If the value of {@code includeSimplifiedGrammar} is true, the document
	 * will contain a simplified BNF description of the grammar.
	 * If the value of {@code includeDotReferenceGraph} is true, a 
	 * GraphViz-style representation of the dependency between the grammar 
	 * rules will also be included.
	 * If the value of {@code gitbookLinkStyle} is true, the document will 
	 * use gitbook-style links and link anchors.
	 */
	override CharSequence formatGrammar(GrammarDoc grammarDoc) {
		Preconditions.checkNotNull(grammarDoc, "grammarDoc");
		
		val Map<AbstractRule, RuleDoc> mapping = grammarDoc.rules.toMap([it|it.rule], [it|it]);

		'''
			<!DOCTYPE html>
			<html lang="en">
			<head>
			  <meta charset="UTF-8">
			  <meta name="viewport" content="width=device-width, initial-scale=1.0">
			  <title>Table of Contents</title>
			  <link rel="stylesheet" href="styles.css">
			</head>
			<body>
			
			<h1> «mainTitle ?: grammarDoc.grammarName»</h1>
			
			«IF !grammarDoc.headComment.getMainDescription.nullOrEmpty»«grammarDoc.headComment.getMainDescription.docCommentFormattingToHtml»«ENDIF»
			
			«IF includeToc»
				«toc(grammarDoc)»
			«ENDIF»
			
			
			<div class="content">
			
			«IF !grammarDoc.grammar.usedGrammars.isEmpty»
				<div id="included-grammars" class="section">
				<h2>Included grammars:</h2>
				<ul>
				«FOR x : grammarDoc.grammar.usedGrammars»
					<li> <code>«x.name»</code> </li>
				«ENDFOR»
				</ul>
				</div>
			«ENDIF»
			
			«val metamodels = grammarDoc.grammar.metamodelDeclarations.filter[!alias.nullOrEmpty]»
			«IF !metamodels.isEmpty»
				<div id="included-metamodels" class="section">
				<h2>Included metamodels:</h2>
				<ul>
				«FOR x : metamodels»
					<li> «x.alias» (<code>«x.EPackage.nsURI»</code>)</li>
				«ENDFOR»
				</ul>
				</div>
			«ENDIF»
			
			<h2> Rules</h2>
			«FOR ruleDoc : grammarDoc.rules»
				«formatRule(ruleDoc, mapping)»			
			«ENDFOR»
			
			«IF includeSimplifiedGrammar»
				<h2> Simplified grammar</h2>
				«FOR rule : allUsedRules(grammarDoc.rules.get(0).rule)»
					<em>«rule.name»</em> ::= «formattedRuleDef(rule.alternatives)»;
					
				«ENDFOR»
			«ENDIF»
			
			«IF includeDotReferenceGraph»
				«dotGraphRef(grammarDoc.rules, grammarDoc.rules.get(0), mapping)»
			«ENDIF»
			
			</div>
			<script src="script.js"></script>
			</body>
			</html>
		'''
	}
	
	/**
	 * Returns a Markdown-formatted document describing the given grammar rule.
	 * <p>
	 * If the value of {@code gitbookLinkStyle} is true, the document will 
	 * use gitbook-style links and link anchors.
	 */
	dispatch def CharSequence formatRule(RuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) {
	}
	def dispatch CharSequence genRuleHeader(RuleDoc ruleDoc) {
	}

	def dispatch CharSequence genRuleHeader(ParserRuleDoc ruleDoc) {
		return 	ruleDocHeaderText(ruleDoc.ruleName, "");	
	}
	dispatch def CharSequence formatRule(ParserRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«ruleDocHeader(ruleDoc.ruleName, "")»
		«ruleDoc.headComment.getMainDescription.docCommentFormattingToHtml»
		
		«validationPartIfExists(ruleDoc.headComment)»
		«examplePartIfExists(ruleDoc.headComment)»
		
		«ruleReferences(ruleDoc, mapping)»
		
		«returns(ruleDoc.rule)»
		
		«ruleToCodeSnippet(ruleDoc.rule)»
		«ruleDocFooter(ruleDoc.ruleName,"")»

	'''


	def dispatch CharSequence genRuleHeader(EnumRuleDoc ruleDoc) {
		return 	ruleDocHeaderText(ruleDoc.ruleName, "enum");	
	}
	dispatch def CharSequence formatRule(EnumRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«ruleDocHeader(ruleDoc.ruleName, "enum")»
		«ruleDoc.headComment.getMainDescription.docCommentFormattingToHtml»
		
		«validationPartIfExists(ruleDoc.headComment)»
		«examplePartIfExists(ruleDoc.headComment)»
		
		Literals:
		<ul>
		«FOR entry : getPerEnumLiteral(ruleDoc).entrySet.sortBy[it.key.name]»
			<li> «entry.key.name» («FOR textLit : entry.value.map[it | it.literalText] SEPARATOR ', '»`«textLit»`«ENDFOR»)
				«val firstCommentedLiteral = entry.value.findFirst[it | it.comment.isPresent && !it.comment.get.mainDescription.isNullOrEmpty]»«IF firstCommentedLiteral !== null» : «textFormatter.italic(firstCommentedLiteral.comment.get.getMainDescription.docCommentFormattingToHtml)»«ENDIF»
		«ENDFOR»
		</ul>
		«ruleToCodeSnippet(ruleDoc.rule)»
	'''
	
	
	private def getPerEnumLiteral(EnumRuleDoc ruleDoc) {
		val Map<EEnumLiteral, List<EnumLiteralDoc>> ret = newHashMap();
		for (enumLiteral : ruleDoc.literals.map[it | it.literalEnum].toSet) {
			ret.put(enumLiteral, ruleDoc.literals.filter[it.literalEnum == enumLiteral].toList);
		}
		return ret;
	}

	def dispatch CharSequence genRuleHeader(TerminalRuleDoc ruleDoc) {
		return 	ruleDocHeaderText(ruleDoc.ruleName, '''terminal«IF ruleDoc.isTerminalFragment» fragment«ENDIF»''');	
	}
	dispatch def CharSequence formatRule(TerminalRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«ruleDocHeader(ruleDoc.ruleName, '''terminal«IF ruleDoc.isTerminalFragment» fragment«ENDIF»''')»
		«ruleDoc.headComment.getMainDescription.docCommentFormattingToHtml»
		
		«validationPartIfExists(ruleDoc.headComment)»
		«examplePartIfExists(ruleDoc.headComment)»
		
		«ruleReferences(ruleDoc, mapping)»
		
		«ruleToCodeSnippet(ruleDoc.rule)»
	'''

	// Private helpers
	
	
	/**
	 * To generate links based on the header content, we must know what that text is.
	 */
	private def ruleDocHeaderText(String ruleName, String ruleType) {
		return '''«ruleName»«IF !ruleType.nullOrEmpty» («ruleType»)«ENDIF»'''
	}
	private def ruleDocHeader(String ruleName, String ruleType) {
		return '''
    	<div id="«toAnchor(ruleDocHeaderText(ruleName,ruleType)).toLowerCase»" class="section">		
    	<h3> «ruleDocHeaderText(ruleName,ruleType)» «IF gitbookLinkStyle»{«toLink(ruleName)»}«ENDIF»</h3>
		'''
	}
	private def ruleDocFooter(String ruleName, String ruleType) {
		return '''</div>'''
	}
	
	
	private def ruleToCodeSnippet(AbstractRule rule) '''
		<pre><code>
		«XtextTokenUtil.tokenTextOrUnknown(rule)»
		</code></pre>
	'''

	private def validationPartIfExists(DocComment headComment) '''
		«IF headComment.getPartsWithTag(VALIDATION_TAG).isEmpty == false»
			<li> <strong>Validation:</strong>
			   «FOR validationPart : headComment.getPartsWithTag(VALIDATION_TAG)»
			   	* «validationPart.getArgument.docCommentFormattingToHtml»
			   «ENDFOR»
			</li>
		«ENDIF»
	'''

	private def examplePartIfExists(DocComment headComment) '''
		«IF headComment.getPartsWithTag(EXAMPLE_TAG).isEmpty == false»
			<ul> <strong>Examples:</strong>
			   «FOR validationPart : headComment.getPartsWithTag(EXAMPLE_TAG)»
			   	<li> «IF DocCommentTextUtil.containsCode(validationPart.getArgument)»«validationPart.getArgument.docCommentFormattingToHtml»«ELSE»«'''`«validationPart.getArgument»`'''.toString.docCommentFormattingToHtml»«ENDIF»</li>
			   «ENDFOR»
			</ul>
		«ENDIF»
	'''
		
	private def ruleReferences(ReferenceRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«val refersTo = ruleDoc.refersTo.sortBy[it | it.name ?: ""]»
		«IF ruleDoc.refersTo.empty == false»
			<strong>Refers to:</strong>
			<ul>
			«FOR ref : refersTo»
				«IF mapping.containsKey(ref)»
					<li> «mapping.get(ref).ruleNameAsLink»</li>
				«ELSE»
					<li> «ref.name»</li>
				«ENDIF»
			«ENDFOR»
			</ul>
			
		«ENDIF»
		«val referredBy = mapping.values.filter(ParserRuleDoc).filter[it | it.getRefersTo().contains(ruleDoc.rule)].toSet.sortBy[it.ruleName]»
		«IF referredBy.empty == false»
			<strong>Referenced by:</strong>
			<ul>
			«FOR ref : referredBy»
				<li> «ref.ruleNameAsLink»</li>
			«ENDFOR»
			</ul>
		«ENDIF»
	'''

	private def returns(ParserRule rule) {
		if (rule.type.metamodel.alias.nullOrEmpty) {
			// it is in the generated metamodel, not so interesting
			return "";
		} else {
			return '''<strong>Returns:</strong> `«rule.type.metamodel.alias»::«rule.type.classifier.name»`'''
		}
	}
	
	private def ruleNameAsLink(RuleDoc rule) {
		
		return textFormatter.link(rule.ruleName, toLink(genRuleHeader(rule).toString.trim));
	}
	
	private def dotGraphRef(List<RuleDoc> rules, RuleDoc rootRule, Map<AbstractRule, RuleDoc> mapping) '''
		<H2> Rule dependencies</H2>
		
		```[graph_ref_goes_here]Graph Reference Goes Here
		```
	'''
	

	/**
	 * Returns a BNF-like simplified representation of the given rule 
	 * definition, with HTML formatting.
	 * @param element Element to be represented.
	 * @param parenNeeded If true and the represented element is not atomic, 
	 * it will be surrounded with parentheses.
	 * @return Simplified textual representation of the given rule definition.
	 */
	private def dispatch CharSequence formattedRuleDef(AbstractElement element, boolean parenNeeded) {
		return '''??«element.class.simpleName»??'''
	}

	private def dispatch CharSequence formattedRuleDef(Void element, boolean parenNeeded) {
		return '''(null)'''
	}

	private def dispatch CharSequence formattedRuleDef(Alternatives element, boolean parenNeeded) {
		return '''«IF parenNeeded && element.elements.size > 1»(«ENDIF»«FOR it : element.elements SEPARATOR ' | '»«formattedRuleDef(it, element.elements.size > 1)»«ENDFOR»«IF parenNeeded && element.elements.size > 1»)«ENDIF»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(UnorderedGroup element, boolean parenNeeded) {
		return '''«IF parenNeeded && element.elements.size > 1»(«ENDIF»«FOR it : element.elements SEPARATOR ' & '»«formattedRuleDef(it, element.elements.size > 1)»«ENDFOR»«IF parenNeeded && element.elements.size > 1»)«ENDIF»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Group element, boolean parenNeeded) {
		return '''«IF parenNeeded && element.elements.size > 1»(«ENDIF»«IF element.guardCondition !== null»<...>«ENDIF»«FOR it : element.elements SEPARATOR '   '»«formattedRuleDef(it, element.elements.size > 1)»«ENDFOR»«IF parenNeeded && element.elements.size > 1»)«ENDIF»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Assignment element, boolean parenNeeded) {
		return '''«formattedRuleDef(element.terminal, true)»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(CrossReference element, boolean parenNeeded) {
		return '''«formattedRuleDef(element.terminal)»«element.cardinality»''';
	}
	
	private def dispatch CharSequence formattedRuleDef(Action element, boolean parenNeeded) {
		return ''
	}
	
	private def dispatch CharSequence formattedRuleDef(NegatedToken element, boolean parenNeeded) {
		return '''!(«formattedRuleDef(element.terminal)»)«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Wildcard element, boolean parenNeeded) {
		return '''_._«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(UntilToken element, boolean parenNeeded) {
		return ''' --> «formattedRuleDef(element.terminal)» «element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Keyword element, boolean parenNeeded) {
		return '''<code>«keywordText(element.value)»</code>«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(RuleCall element, boolean parenNeeded) {
		return '''_«element.rule.name»_«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(EnumLiteralDeclaration element, boolean parenNeeded) {
		return formattedRuleDef(element.literal);
	}
	
	private def dispatch CharSequence formattedRuleDef(CharacterRange element, boolean parenNeeded) {
		return '''[«formattedRuleDef(element.left)»..«formattedRuleDef(element.right)»]«element.cardinality»''';
	}
	
	private def String keywordText(String keywordValue) {
		return keywordValue.replace("\t", "\\t").replace("\r", "\\r").replace("\n", "\\n");
	}
	
	private def String docCommentFormattingToHtml(String text) {
		val escaped = textFormatter.escape(text);
		val String resolved = DocCommentTextUtil.resolveLinks(escaped, textFormatter, [it | toLink(it)]);
		return DocCommentTextUtil.format(resolved, textFormatter);
	}
	
	private def String toLink(String text) {
		if (text.trim().matches("^https?://.*")) {
			return text;
		} else {
			// First, remove all non word text - in our case, we only need to check for parens
			// And, compress all multiple spaces to singles
			var temp = toAnchor(text)
			
			if (gitbookLinkStyle) {
				return temp;
			} else {
				return temp.toLowerCase;
			}
		}
	}
}
