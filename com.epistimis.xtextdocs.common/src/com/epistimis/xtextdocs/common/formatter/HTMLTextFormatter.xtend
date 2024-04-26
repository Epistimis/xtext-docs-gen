package com.epistimis.xtextdocs.common.formatter

import java.util.List

class HTMLTextFormatter implements ITextFormatter {
	public static final HTMLTextFormatter INSTANCE = new HTMLTextFormatter();

	private new() {
	}
	
	override escape(String original) {
		// FIXME do not escape inside "`"
		var ret = original;
		if (!original.contains("@code") && !original.contains("`")) { // quickfix
			ret = "<pre><code>"+ original + "</code></pre>";
		}
		return ret;
	}

	override bold(String original) {
		if (original.isNullOrEmpty) {
			return "";
		}
		
		// The '**' does not support multiline!
		return '''<b>«original»</b>''';
	}

	override codeBlock(String original) {
		return '''
		<pre><code>
		«original»
		</code></pre>''';
	}

	override inlineCode(String original) {
		if (original.isNullOrEmpty) {
			return "";
		}
		
		return '''<pre><code>«original»</code></pre>''';
	}

	override italic(String original) {
		if (original.isNullOrEmpty) {
			return "";
		}
		
		// The '_' does not support multiline!
		return '''<i>«original»</i>''';
	}

	override newLine() {
		return '''
			
			''';
	}

	override String link(String linkText, String target) {
		return '''<a href="#«target»" >«linkText»</a>''';
	}
	
	override unorderedList(List<String> originals) {
		return '''
			<ul>
			«FOR line : originals»
				<li>«line»</li>
			«ENDFOR»
			</ul>
		'''
	}
}
