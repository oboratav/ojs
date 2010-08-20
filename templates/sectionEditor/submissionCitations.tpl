<!-- templates/sectionEditor/submissionCitations.tpl -->

{**
 * submissionCitations.tpl
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Submission citations.
 *}
{strip}
{translate|assign:"pageTitleTranslated" key="submission.page.citations" id=$submission->getId()}
{assign var="pageCrumbTitle" value="submission.citations"}
{include file="common/header.tpl"}
{/strip}

<ul class="menu">
	<li><a href="{url op="submission" path=$submission->getId()}">{translate key="submission.summary"}</a></li>
	{if $canReview}<li><a href="{url op="submissionReview" path=$submission->getId()}">{translate key="submission.review"}</a></li>{/if}
	{if $canEdit}<li><a href="{url op="submissionEditing" path=$submission->getId()}">{translate key="submission.editing"}</a></li>{/if}
	<li><a href="{url op="submissionHistory" path=$submission->getId()}">{translate key="submission.history"}</a></li>
	<li class="current"><a href="{url op="submissionCitations" path=$submission->getId()}">{translate key="submission.citations"}</a></li>
</ul>

<script type="text/javascript">
	$(function() {ldelim}
		{if $unprocessedCitations !== false}
			// Activate "Refresh Citation List" button.
			$('#refreshCitationListButton').click(function() {ldelim}
				var $citationGrid = $('#citationGridContainer');

				// Activate the throbber.
				actionThrobber('#citationGridContainer');

				// Trigger the throbber.
				$citationGrid.triggerHandler('actionStart');

				// Reload the citation list.
				$.getJSON('{$citationGridUrl}&refresh=1', function(jsonData) {ldelim}
					// Stop the throbber.
					$citationGrid.triggerHandler('actionStop');

					if (jsonData.status === true) {ldelim}
						// Replace the grid.
						$citationGrid.html(jsonData.content);
					{rdelim} else {ldelim}
						// Display the error message.
						alert(jsonData.content);
					{rdelim}

					// Check whether all missing citations
					// have been added.
					var unprocessedCitationIds = [{strip}
						{foreach name=unprocessedCitations from=$unprocessedCitations item=unprocessedCitation}
							{$unprocessedCitation->getId()}
							{if !$smarty.foreach.unprocessedCitations.last},{/if}
						{/foreach}
					{/strip}];
					var missingIds = false;
					for (var i in unprocessedCitationIds) {ldelim}
						if ($('#component-grid-citation-citationgrid-row-'+unprocessedCitationIds[i]).length == 0) {ldelim}
							missingIds = true;
							break;
						{rdelim}
					{rdelim}

					// Remove the refresh button if all originally
					// missing citations have been processed by now.
					if (!missingIds) {ldelim}
						$('#refreshCitationListMessage').remove();
					{rdelim}
				{rdelim});
			{rdelim});
		{/if}

		// Vertical splitter.
		$('#citationEditorCanvas').splitter({ldelim}
			splitVertical:true,
			A:$('#citationEditorNavPane'),
			minAsize:200,
			B:$('#citationEditorDetailPane'),
			minBsize:300
		{rdelim});

		// Main tabs.
		$mainTabs = $('#citationEditorMainTabs').tabs({ldelim}
			show: function(e, ui) {ldelim}
				// Make sure the citation editor is correctly sized when
				// opened for the first time.
				if (ui.panel.id == 'citationEditorTabEdit') {ldelim}
					$('#citationEditorCanvas').triggerHandler('splitterRecalc');
				{rdelim}
				{if !$citationEditorConfigurationError}
					if (ui.panel.id == 'citationEditorTabExport') {ldelim}
						$('#citationEditorExportPane').html('<div id="citationEditorExportThrobber" class="throbber"></div>');
						$('#citationEditorExportThrobber').show();

						// Re-load export tab whenever it is shown.
						$.getJSON('{$citationExportUrl}', function(jsonData) {ldelim}
							if (jsonData.status === true) {ldelim}
								$("#citationEditorExportCanvas").replaceWith(jsonData.content);
							{rdelim} else {ldelim}
								// Alert that loading failed
								alert(jsonData.content);
							{rdelim}
						{rdelim});
					{rdelim}
				{/if}
			{rdelim}
		{rdelim});

		{if !$introductionHide}
			// Feature to disable introduction message.
			$('#introductionHide').click(function() {ldelim}
				$.getJSON(
					'{url router=$smarty.const.ROUTE_COMPONENT component="api.user.UserApiHandler" op="setUserSetting"}?setting-name=citation-editor-hide-intro&setting-value='+($(this).attr('checked')===true ? 'true' : 'false'),
					function(jsonData) {ldelim}
						if (jsonData.status !== true) {ldelim}
							alert(jsonData.content);
						{rdelim}
					{rdelim}
				);
			{rdelim});
		{/if}

		{if $citationEditorConfigurationError}
			// Disable editor when not properly configured.
			$mainTabs.tabs('option', 'disabled', [1, 2]);
		{/if}

		// Throbber feature (binds to ajaxAction()'s 'actionStart' event).
		actionThrobber('#citationEditorDetailCanvas');

		// Fullscreen feature.
		var $citationEditor = $('#submissionCitations');
		var beforeFullscreen;
		$('#fullScreenButton').click(function() {ldelim}
			if ($citationEditor.hasClass('fullscreen')) {ldelim}
				// Going back to normal: Restore saved values.
				$citationEditor.removeClass('fullscreen');
				$('.composite-ui>.ui-tabs').css('margin-top', beforeFullscreen.topMargin);
				$('.composite-ui>.ui-tabs div.main-tabs').each(function() {ldelim}
					$(this).css('height', beforeFullscreen.height);
				{rdelim});
				$('.composite-ui div.two-pane>div.left-pane .scrollable').first().css('height', beforeFullscreen.navHeight);

				$('body').css('overflow', 'auto');
				window.scroll(beforeFullscreen.x, beforeFullscreen.y);
				$(this).text('{translate key="common.fullscreen"}');
			{rdelim} else {ldelim}
				// Going fullscreen:
				// 1) Save current values.
				beforeFullscreen = {ldelim}
					topMargin: $('.composite-ui>.ui-tabs').css('margin-top'),
					height: $('.composite-ui>.ui-tabs div.main-tabs').first().css('height'),
					navHeight: $('.composite-ui div.two-pane>div.left-pane .scrollable').first().css('height'),
					x: $(window).scrollLeft(),
					y: $(window).scrollTop()
				{rdelim};

				// 2) Set values needed to go fullscreen.
				$('body').css('overflow', 'hidden');
				$citationEditor.addClass('fullscreen');
				$('.composite-ui>.ui-tabs').css('margin-top', '0');
				canvasHeight=$(window).height()-$('ul.main-tabs').height();
				$('.composite-ui>.ui-tabs div.main-tabs').each(function() {ldelim}
					$(this).css('height', canvasHeight+'px');
				{rdelim});
				$('.composite-ui div.two-pane>div.left-pane .scrollable').first().css('height', (canvasHeight-30)+'px');
				window.scroll(0,0);
				$(this).text('{translate key="common.fullscreenOff"}');
			{rdelim}

			// Resize 2-pane layout.
			$('.two-pane').css('width', '100%').triggerHandler('splitterRecalc');
		{rdelim});

		// Resize citation editor in fullscreen mode
		// when the browser window is being resized.
		$(window).resize(function() {ldelim}
			// Adjust editor height to new window height when in fullscreen mode. 
			if ($citationEditor.hasClass('fullscreen')) {ldelim}
				canvasHeight=$(window).height()-$('ul.main-tabs').height();
				$('.composite-ui>.ui-tabs div.main-tabs').each(function() {ldelim}
					$(this).css('height', canvasHeight+'px');
				{rdelim});
				$('.composite-ui div.two-pane>div.left-pane .scrollable').first().css('height', (canvasHeight-30)+'px');
			{rdelim}
			
			// Adjust 2-pane layout to new window width.
			$('.two-pane').css('width', '100%').triggerHandler('splitterRecalc');
		{rdelim});
	{rdelim});
</script>

{* CSS - FIXME: will be moved to JS file as soon as development is done *}
{literal}
<style type="text/css">
	/* General: auto-complete */
	.ui-autocomplete.ui-menu .ui-menu-item a {
		text-align: left;
	}

	/* Composite UI: general */
	.composite-ui button {
		white-space: nowrap;
	}

	/* Composite UI: general: browser specific */
	.browserChrome .composite-ui select,
	.browserChrome .composite-ui button,
	.browserSafari .composite-ui select,
	.browserSafari .composite-ui button {
		padding: 2px; /* Fixes WebKit browsers' ugly buttons and drop-downs. */
	}

	/* Composite UI: main tabs */
	.composite-ui>.ui-tabs {
		margin-top: 20px;
		padding: 0;
		border: 0 none;
	}

	.composite-ui>.ui-tabs ul.main-tabs {
		background: none #FBFBF3;
		border: 0 none;
		padding: 0;
	}

	.composite-ui>.ui-tabs ul.main-tabs li.ui-tabs-selected a {
		color: #555555;
	}

	.composite-ui>.ui-tabs ul.main-tabs li.ui-tabs-selected {
		padding-bottom: 2px;
		background: none #CED7E1;
	}

	.composite-ui>.ui-tabs ul.main-tabs a {
		color: #CCCCCC;
		font-size: 1.5em;
		padding: 0.2em 3em;
	}

	.composite-ui>.ui-tabs div.main-tabs {
		padding: 0;
		padding: 0;
	}

	.composite-ui>.ui-tabs div.main-tabs>.canvas {
		height: 100%;
	}

	/* Composite UI: canvas and pane */
	.composite-ui div.canvas {
		margin: 0;
		padding: 0;
		background-color:#EFEFEF;
		width: 100%;
	}

	.composite-ui div.pane {
		border: 1px solid #B6C9D5;
		background-color: #EFEFEF;
		height: 100%;
	}

	.composite-ui div.pane div.wrapper {
		padding: 30px;
	}

	.composite-ui .scrollable {
		overflow-y: auto;
		overflow-x: hidden;
	}

	/* Composite UI: fullscreen support */
	.fullscreen {
		display: block;
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: 999;
		margin: 0;
		padding: 0;
		background: inherit;
		font-size: 120%;
	}

	#fullScreenButton {
		float: right;
		margin-top: 5px;
	}

	/* Composite UI: generic help or info message */
	.composite-ui div.pane div.help-message {
		margin: 40px;
		padding-left: 30px;
		/* FIXME: change path when moving this to its own file */
		background: transparent url("../../../../lib/pkp/templates/images/icons/alert.gif") no-repeat;
	}

	/* Composite UI: text pane layout */
	.composite-ui div.canvas>div.text-pane {
		background-color: #CED7E1;
		padding: 0 30px;
	}

	/* Composite UI: grids as sub-components */
	.composite-ui div.grid table {
		border: 0 none;
	}

	.composite-ui div.grid th .options {
		margin: 0;
	}

	.composite-ui div.grid th .options a {
		margin: 0;
	}

	.composite-ui div.grid td {
		border-bottom: 1px solid #B6C9D5;
	}

	.composite-ui div.grid .row_actions a,
	.composite-ui div.grid .options a {
		text-decoration: none; /* Opera */
		padding-right: 5px;
	}

	/* Composite UI: 2-pane layout */
	.composite-ui div.two-pane table.pane_header {
		width: 100%;
		border-collapse: collapse; /* Required for IE7 to remove table borders. */
	}

	.composite-ui div.two-pane table.pane_header tr {
		height: 30px; /* Must be set for tr rather than th for Chromium compat. */
		padding: 4px 0;
	}

	.composite-ui div.two-pane table.pane_header th {
		padding: 0 4px; /* Padding top/bottom must be 0 for IE7. */
		background-color: #CED7E1;
		color: #20538D;
		vertical-align: middle;
	}

	.composite-ui div.two-pane>div.left-pane,
	.composite-ui div.two-pane>div.right-pane {
		float: left;
	}

	.composite-ui div.two-pane>div.left-pane {
		width: 25%;
	}

	/* Composite UI: 2-pane layout - navigation list */
	.composite-ui div.two-pane>div.left-pane div.grid .scrollable {
		position: relative; /* Required to fix overflow:auto + inner table scrolling bug in IE7, see <http://snook.ca/archives/html_and_css/position_relative_overflow_ie/>. */
		zoom: 1; /* Sets proprietary hasLayout property in IE < 8 - required for scrollbar to appear, see <http://stackoverflow.com/questions/139000/div-with-overflowauto-and-a-100-wide-table-problem> for a similar problem. */
	}

	.composite-ui div.two-pane>div.left-pane div.grid div.row_container {
		background-color: #FFFFFF;
	}

	.composite-ui div.two-pane>div.left-pane div.grid div.clickable-row:hover,
	.composite-ui div.two-pane>div.left-pane div.grid div.clickable-row:hover div.row_file {
		background-color: #B6C9D5;
		cursor: pointer;
	}

	.composite-ui div.two-pane>div.left-pane div.grid tr.approved-citation .row_container {
		border-left: 3px solid #20538D;
		padding-left: 22px;
	}

	.composite-ui div.two-pane>div.left-pane div.grid tr.approved-citation .row_actions {
		width: 22px;
		left: -3px;
	}

	/* Composite UI: 2-pane layout - splitbar */
	.composite-ui div.two-pane>div.splitbarV {
		float: left;
		width: 6px;
		height: 100%;
		line-height: 0;
		font-size: 0;
		border: solid 0px;
		/* FIXME: change path when moving this to its own file */
		background: #cbe1fb url(../../../../lib/pkp/styles/splitter/ui-bg_pane.gif) 0% 50%;
	}

	.composite-ui div.two-pane>div.splitbarV.working,
	.composite-ui div.two-pane>div.splitbuttonV.working {
		 -moz-opacity: .50;
		 filter: alpha(opacity=50);
		 opacity: .50;
	}

	/* Composite UI: 2-pane layout - detail editor */
	.composite-ui div.two-pane>div.right-pane {
		position: relative;
	}

	.composite-ui div.two-pane>div.right-pane div.wrapper {
		position: absolute;
		top: 30px;
		bottom: 0;
		left: 0;
		right: 0;
		padding-top: 10px;
		padding-bottom: 10px;
	}

	.composite-ui div.two-pane>div.right-pane div.wrapper.with-pane-actions {
		bottom: 60px;
		padding-bottom: 0;
	}

	.composite-ui div.two-pane>div.right-pane div.pane-actions {
		position: absolute;
		margin: 0px;
		bottom: 0;
		height: 40px;
		width: 100%;
	}

	.composite-ui div.two-pane>div.right-pane div.pane-actions>div {
		padding: 0 30px;
	}

	.composite-ui div.two-pane>div.right-pane div.pane-actions button {
		float: right;
	}

	.composite-ui div.two-pane>div.right-pane div.pane-actions button.secondary-button {
		float: left;
	}

	.composite-ui div.two-pane>div.right-pane .form-block {
		margin-bottom: 40px;
		clear: both;
	}

	/* Composite UI: 2-pane layout - detail editor grids */
	.composite-ui div.two-pane>div.right-pane div.grid table {
		border-top: 1px solid #B6C9D5;
	}

	.composite-ui div.two-pane>div.right-pane div.grid td,
	.composite-ui div.two-pane>div.right-pane div.grid .row_actions,
	.composite-ui div.two-pane>div.right-pane div.grid .row_file {
		height: auto;
		min-height: 0;
		line-height: 1em;
		text-align: left;
	}

	.composite-ui div.two-pane>div.right-pane div.grid .row_container {
		background-color: #FFFFFF;
		padding-right: 30px;
		padding-right: 5px;
	}

	.composite-ui div.two-pane>div.right-pane div.grid .row_actions {
		right: 26px;
		padding-top: 2px;
	}

	.composite-ui div.two-pane>div.right-pane div.grid .row_actions a {
		display: block;
		padding-bottom: 4px;
	}

	.composite-ui div.two-pane>div.right-pane div.grid .row_file {
		width: auto;
		padding: 0;
	}

	/* Citation editor: editor height */
	#submissionCitations.composite-ui div.main-tabs {
		height: 600px;
	}

	#submissionCitations.composite-ui div.two-pane>div.left-pane div.grid .scrollable {
		height: 570px; /* This is necessary for overflow. */
	}

	/* Citation editor: citation list */
	.composite-ui div.two-pane>div.left-pane div.grid tr.current-item div.row_file,
	.composite-ui div.two-pane>div.left-pane div.grid tr.current-item div.row_container {
		background-color: #B6C9D5;
	}

	/* Citation editor: citation detail editor */
	#editCitationForm .actions {
		float: right;
	}

	#editCitationForm .options-head .ui-icon {
		float: left;
	}

	#editCitationForm .option-block {
		margin-bottom: 10px;
	}

	#editCitationForm .option-block p {
		margin: 5px 0 0 0;
	}

	#editCitationForm .option-block-option {
		float: left;
		margin-left: 5px;
	}

	#editCitationForm .clear {
		clear: both;
	}

	/* Citation editor: citation detail editor - before/after fields */
	#submissionCitations.composite-ui div.two-pane>div.right-pane .citation-comparison {
		margin-bottom: 10px;
	}

	#submissionCitations.composite-ui div.two-pane>div.right-pane .citation-comparison div.value {
		border: 1px solid #AAAAAA;
		padding: 5px;
		background-color: #FFFFFF;
	}

	#editableRawCitation div.value {
		margin-right: 15px;
	}

	#editableRawCitation div.value>div {
		padding-right: 14px; /* Conditional div only seen by IE < 8 fixing textarea sizing bug in IE 7. */
	}

	#editableRawCitation textarea.textarea {
		width: 100%;
		padding: 5px;
		overflow-y: auto; /* Hide scrollbar in IE7. */
	}

	#rawCitationEditingExpertOptions .option-block {
		padding-left: 30px;
	}

	#rawCitationWithMarkup div.value {
		margin-right: 25px;
	}

	#rawCitationWithMarkup a {
		display: block;
		width: 14px;
		height: 14px;
		margin-top: 1em;
		margin-left: 0;
	}

	#generatedCitationWithMarkup span {
		cursor: default;
	}

	#submissionCitations.composite-ui div.two-pane>div.right-pane .citation-comparison span,
	#editableRawCitation textarea.textarea {
		font-size: 1.3em;
	}

	#submissionCitations.composite-ui div.two-pane>div.right-pane .citation-comparison-deletion {
		color: red;
		text-decoration: line-through;
	}

	#submissionCitations.composite-ui div.two-pane>div.right-pane .citation-comparison-addition {
		color: green;
		text-decoration: underline;
	}

	#citationFormErrorsAndComparison .throbber {
		height: 150px;
	}

	/* Citation editor: citation detail editor - improvement options: manual editing */
	.composite-ui div.two-pane>div.right-pane div.grid table {
		table-layout: fixed; /* IE7 hack to ensure that input fields fill 100% of the cell without overflow */
	}

	.composite-ui div.two-pane>div.right-pane div.grid td.first_column {
		width: 150px;
	}

	.composite-ui div.two-pane>div.right-pane div.grid td.first_column select {
		width: 100%;
	}

	/* Citation editor: citation detail editor - improvement options: author query */
	#authorQueryResult {
		float: left;
	}

	/* Citation editor: citation detail editor - internal citation service result tabs */
	#citationImprovementResultsBlock .options-head.active {
		margin-top: 40px;
	}

	#citationImprovementResultsBlock div.grid td {
		font-size: 1em;
		line-height: 1.3em;
	}

	#citationImprovementResultsBlock div.grid td.citation-source-action-cell {
		text-align: right;
	}

	#citationImprovementResultsBlock div.grid tr.citation-source-action-row td {
		border-bottom: 0 none;
		text-align: right;
		padding-right: 0;
	}

	/* Citation editor: citation export */
	#citationEditorExportPane {
		position: relative;
	}
	
	#citationEditorExportPane .scrollable {
		/* The following settings are necessary for overflow. */
		position: absolute;
		top: 11em;
		bottom: 30px;
		left: 30px;
		right: 30px;
	}
</style>
{/literal}

{if $unprocessedCitations !== false}
	<div id="refreshCitationListMessage" class="composite-ui">
		<p>
			<span class="formError">{translate key="submission.citations.editor.unprocessedCitations"}</span>
		</p>
		<button id="refreshCitationListButton" type="button" title="{translate key="submission.citations.editor.unprocessedCitationsButtonTitle"}">{translate key="submission.citations.editor.unprocessedCitationsButton"}</button>
	</div>
{/if}
<div id="submissionCitations" class="composite-ui">
	<div id="citationEditorMainTabs">
		<button id="fullScreenButton" type="button">{translate key="common.fullscreen"}</button>
		<ul class="main-tabs">
			{if !$introductionHide}<li><a href="#citationEditorTabIntroduction">{translate key="submission.citations.editor.introduction"}</a></li>{/if}
			<li><a href="#citationEditorTabEdit">{translate key="submission.citations.editor.edit"}</a></li>
			<li><a href="#citationEditorTabExport">{translate key="submission.citations.editor.export"}</a></li>
		</ul>
		{if !$introductionHide}
			<div id="citationEditorTabIntroduction" class="main-tabs">
				<div id="citationEditorIntroductionCanvas" class="canvas">
					<div id="citationEditorIntroductionPane" class="pane text-pane">
						<div class="help-message">
							{capture assign="citationSetupUrl"}{url page="manager" op="setup" path="3" anchor="metaCitationEditing"}{/capture}
							{if $citationEditorConfigurationError}
								{translate key=$citationEditorConfigurationError citationSetupUrl=$citationSetupUrl}
								{translate key="submission.citations.editor.introduction.introductionMessage" citationSetupUrl=$citationSetupUrl}
							{else}
								{translate key="submission.citations.editor.introduction.introductionMessage" citationSetupUrl=$citationSetupUrl}
								<input id="introductionHide" type="checkbox" />{translate key="submission.citations.editor.details.dontShowMessageAgain"}
							{/if}
						</div>
					</div>
				</div>
			</div>
		{/if}
		<div id="citationEditorTabEdit" class="main-tabs">
			<div id="citationEditorCanvas" class="canvas two-pane">
				<div id="citationEditorNavPane" class="pane left-pane">
					{if !$citationEditorConfigurationError}
						{load_url_in_div id="#citationGridContainer" loadMessageId="submission.citations.editor.loadMessage" url="$citationGridUrl"}
					{/if}
				</div>
				<div id="citationEditorDetailPane" class="pane right-pane">
					<table class="pane_header"><thead><tr><th>&nbsp;</th></tr></thead></table>
					<div id="citationEditorDetailCanvas" class="canvas">
						<div class="wrapper scrollable">
							<div class="help-message">{$initialHelpMessage}</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div id="citationEditorTabExport" class="main-tabs">
			<div id="citationEditorExportCanvas" class="canvas">
				<div id="citationEditorExportPane" class="pane text-pane"></div>
			</div>
		</div>
	</div>
</div>

{include file="common/footer.tpl"}

<!-- / templates/sectionEditor/submissionCitations.tpl -->

