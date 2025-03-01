<?php

/**
 * @file pages/manageIssues/ManageIssuesHandler.inc.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class IssueManagementHandler
 * @ingroup pages_editor
 *
 * @brief Handle requests for issue management in publishing.
 */

use APP\handler\Handler;
use APP\template\TemplateManager;
use PKP\security\Role;
use PKP\security\authorization\PKPSiteAccessPolicy;

class ManageIssuesHandler extends Handler
{
    /** @var Issue Issue associated with the request */
    public $issue;

    /** @copydoc PKPHandler::_isBackendPage */
    public $_isBackendPage = true;

    /**
     * Constructor
     */
    public function __construct()
    {
        parent::__construct();
        $this->addRoleAssignment(
            [Role::ROLE_ID_MANAGER],
            [
                'index',
            ]
        );
    }

    /**
     * @copydoc PKPHandler::authorize()
     */
    public function authorize($request, &$args, $roleAssignments)
    {
        $this->addPolicy(new PKPSiteAccessPolicy($request, null, $roleAssignments));
        return parent::authorize($request, $args, $roleAssignments);
    }

    /**
     * Displays the issue listings in a tabbed interface.
     *
     * @param array $args
     * @param PKPRequest $request
     *
     * @return string Response contents.
     */
    public function index($args, $request)
    {
        $this->setupTemplate($request);

        $templateMgr = TemplateManager::getManager($request);
        $templateMgr->assign([
            'pageTitle' => __('editor.navigation.issues')
        ]);
        return $templateMgr->display('manageIssues/issues.tpl');
    }
}
