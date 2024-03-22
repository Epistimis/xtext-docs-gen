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

package com.epistimis.xtextdocs.xtext.fragment

import com.epistimis.xtextdocs.xtext.DocsGenerator
import com.epistimis.xtextdocs.xtext.formatter.IGrammarDocsFormatter
import com.google.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.Grammar
import org.eclipse.xtext.xtext.generator.AbstractXtextGeneratorFragment
import org.eclipse.xtext.xtext.generator.model.FileAccessFactory
import org.eclipse.xtend2.lib.StringConcatenationClient

/**
 * Documentation generation fragment to be used in the Xtext generation workflow.
 * <p>
 * Contains ideas from https://www.eclipse.org/forums/index.php/t/1067192/ .
 */
class DocsGeneratorFragment extends AbstractXtextGeneratorFragment {
	final static Logger LOG = Logger.getLogger(DocsGeneratorFragment);

	Grammar grammar;

	@Inject FileAccessFactory fileAccessFactory

	/**
	 * The file name of the generated grammar documentation (with or without the type extension).
	 * If the file extension is not specified, then the extension defined for the formatter is used.sd
	 * <p>
	 * Mandatory.
	 */
	@Accessors String outputFileName

	/**
	 * The formatter to be used to generate the grammar documentation.
	 * <p>
	 * Mandatory.
	 */
	@Accessors IGrammarDocsFormatter formatter

	@Inject
	def void init(Grammar grammar) {
		this.grammar = grammar;
	}

	override generate() {
		LOG.info("Generating grammar documentation");

		// Error handling (without breaking the workflow)
		if (grammar === null) {
			LOG.error("Unknown 'grammar'");
			return;
		}
		if (outputFileName === null) {
			LOG.error("Unknown 'outputFileName'");
			return;
		}
		if (formatter === null) {
			LOG.error("Unknown 'formatter'");
			return;
		}
		/** Add the appropriate extension based on the formatter type */
		if (outputFileName.lastIndexOf('.') == -1) {
			outputFileName = outputFileName + formatter.outputFileExtension;
		}
		// Generation of the textual output using the given formatter
		val textFileAccess = fileAccessFactory.createTextFile(
			outputFileName, '''«DocsGenerator.generateFormattedDoc(grammar, formatter)»''');
		textFileAccess.writeTo(projectConfig.runtime.root)

		/**
		 * All graphviz files are in DOT format, so the extension is fixed.
		 */
		val graphFileName = outputFileName.substring(0, outputFileName.lastIndexOf('.'))+ ".dot";
		val content = DocsGenerator.generateDOTGraph(grammar, formatter);
		if (content.length > 0) {
			// Only create the DOT file if there is something to put into it
			val graphFileAccess = fileAccessFactory.createTextFile(
				graphFileName, '''«content»''');
			graphFileAccess.writeTo(projectConfig.runtime.root)
//			val Runtime rt = Runtime.getRuntime();
//			val Process pr = rt.exec("/opt/bin/homebrew/dot "+graphFileName);
//			val ret = pr.waitFor();
		}

		LOG.info('''Grammar documentation using '«formatter.class.simpleName»' written to '«outputFileName»' ''');
	}
}
