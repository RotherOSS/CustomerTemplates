// --
// OTOBO is a web-based ticketing system for service organisations.
// --
// Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
// Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.io/
// --
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.TicketAction
 * @memberof Core.Agent
 * @author
 * @description
 *      This namespace contains functions for all ticket action popups.
 */
Core.Agent.TicketAction = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.Agent.TicketAction
     * @function
     * @description
     *      This function sets customer template related events.
     */
    TargetNS.Init = function () {
        // change standard template
        $('#StandardTemplateID').on('change', function () {
            Core.Agent.TicketAction.ConfirmTemplateOverwrite('RichText', $(this), function () {
	        Core.AJAX.FormUpdate($('#CustomerTicket'), 'AJAXUpdate', 'StandardTemplateID');
            });
            return false;
        });

        if ( $('#StandardTemplateID').children().length == 2 ) {
            $("#StandardTemplateID").trigger('change');
        }
    };

    /**
     * @name ConfirmTemplateOverwrite
     * @memberof Core.Agent.TicketAction
     * @function
     * @param {String} FieldName - The ID of the content field (textarea or RTE). ID without selector (#).
     * @param {jQueryObject} $TemplateSelect - Selector of the dropdown element for the template selection.
     * @param {Function} Callback - Callback function to execute if overwriting is confirmed.
     * @description
     *      After a template was selected, this function lets the user confirm that all already existing content
     *      in the textarea or RTE will be overwritten with the template content.
     */
    TargetNS.ConfirmTemplateOverwrite = function (FieldName, $TemplateSelect, Callback) {
        var Content = '',
            LastValue = $TemplateSelect.data('LastValue') || '';
        // Fallback for non-richtext content
        Content = $('#' + FieldName).val();

        // get RTE content
        if (typeof CKEditorInstances !== 'undefined' && CKEditorInstances[FieldName]) {
            Content = CKEditorInstances[FieldName].getData();
        }

        // if content already exists let user confirm to really overwrite that content with a template
        if (
            Content.length &&
            !window.confirm(Core.Language.Translate('Setting a template will overwrite any text or attachment.') + ' ' + Core.Language.Translate('Do you really want to continue?')))
            {
                // if user cancels confirmation, reset template selection
                $TemplateSelect.val(LastValue).trigger('redraw');

        }
        else if ($.isFunction(Callback)) {
            Callback();
            $TemplateSelect.data('LastValue', $TemplateSelect.val());
        }
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.TicketAction || {}));
