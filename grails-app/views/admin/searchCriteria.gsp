%{--
  - ﻿Copyright (C) 2013 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="adminLayout"/>
        <title>ALA Images - Admin - Search Criteria</title>
    </head>

    <body>

        <script type="text/javascript">

            $(document).ready(function() {

                $("#btnAddCriteria").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'admin', action:'newSearchCriteriaDefinition')}";
                });

                $(".btnEditCriteria").click(function(e) {
                    var criteriaId = $(this).parents("tr[searchCriteriaDefinitionId]").attr("searchCriteriaDefinitionId");
                    if (criteriaId) {
                        window.location = "${createLink(controller: 'admin', action:'editSearchCriteriaDefinition')}?searchCriteriaDefinitionId=" + criteriaId;
                    }
                });

                $(".btnDeleteCriteria").click(function(e) {
                    var criteriaId = $(this).parents("tr[searchCriteriaDefinitionId]").attr("searchCriteriaDefinitionId");
                    if (criteriaId) {
                        if (confirm("Are you sure you want to delete this search criteria definition?")) {
                            window.location = "${createLink(controller: 'admin', action:'deleteSearchCriteriaDefinition')}?searchCriteriaDefinitionId=" + criteriaId;
                        }
                    }
                });

                $("#btnImport").click(function(e) {
                    e.preventDefault();
                    window.location="${createLink(action:'selectImportFile', params:[importType:'searchCriteriaDefinitions'])}";
                });

                $("#btnExport").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(action:'exportSearchCriteriaDefinitions')}";
                });

            });

        </script>

        <content tag="pageTitle">Search Criteria</content>

        <content tag="adminButtonBar">
            <button id="btnImport" class="btn btn-small"><i class="icon-upload"></i>&nbsp;Import criteria</button>
            <button id="btnExport" class="btn btn-small"><i class="icon-download-alt"></i>&nbsp;Export criteria</button>
            <button class="btn btn-small btn-primary" id="btnAddCriteria"><i class="icon-plus icon-white"></i>&nbsp;Add Criteria Definition</button>
        </content>

        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Value Type</th>
                    <th>Description</th>
                    <th>Field</th>
                    <th>Units</th>
                    <th style="min-width: 80px">Actions</th>
                </tr>
            </thead>
            <tbody>
                <g:each in="${criteriaDefinitions}" var="criteria">
                    <tr searchCriteriaDefinitionId="${criteria.id}">
                        <td>${criteria.name}</td>
                        <td>${criteria.type}</td>
                        <td>${criteria.valueType}</td>
                        <td>${criteria.description}</td>
                        <td>${criteria.fieldName}</td>
                        <td>${criteria.units}</td>
                        <td style="">
                            <button class="btn btn-mini btn-danger btnDeleteCriteria"><i class="icon-remove icon-white"></i></button>
                            <button class="btn btn-mini btnEditCriteria"><i class="icon-edit"></i></button>
                        </td>
                    </tr>
                </g:each>
            </tbody>
        </table>
    </body>

</html>