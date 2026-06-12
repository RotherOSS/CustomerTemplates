.. image:: ../images/otobo-logo.png
   :align: center

.. toctree::
    :maxdepth: 2
    :caption: Contents

Sacrifice to Sphinx
===================

Overview
========
Summary
-------
Provides the Customer interface with the standard templates feature.

Introduction
------------
This package enhances the standard templates functionality present in the Agent interface for application on the Customer interface. The Customer user can create tickets and responses by choosing from a selection of typical pre-defined texts.

The management interface for the new Customer templates is common to the one of the existing Agent templates, with the only difference being that the Customer templates must be assigned with either one of the *Customer Create* or *Customer Answer* types.

A template may be assigned to one or more queues, so that the list of available templates will depend on the assigned templates for its queue. Alternatively, a template can also be assigned to one or more services, so that the list of available templates will depend on the service that the ticket is assigned to. However, on the ticket creation or ticket replying interface, the list of assigned templates depends permanently on only one of these criteria, which is set via configuration.

In the circumstance of existing only one template available, a configuration option exists that allows the template to be selected automatically, avoiding the need for user interaction. In those cases in which no user interaction is needed the *Template* field is hidden and the *Body* field contains the template text.

Common Usecases
---------------

**Template Definition**

Setting up and managing (editing, deleting, etc.) Customer Templates is the same as `setting up and managing templates for the Agent Interface <https://doc.otobo.de/manual/admin/10.1/en/content/ticket-settings/templates.html>`_, with the only difference being that upon template creation or edition, a customer template type must be assigned the *Customer Create* or *Customer Answer* type, depending on whether the customer user will use the template to create a new ticket or reply to an existing one, respectively.

**Associaton with queues**

The association of a customer template to a given queue is done the same way as `in the Agent Interface <https://doc.otobo.de/manual/admin/10.1/en/content/ticket-settings/templates-queues.html>`_.

**Associaton with services**

The process is analogous to the association with queues, as mentioned above, but using instead the Templates-Services module of the Ticket Settings group.

**Using Customer Templates to create tickets on the Customer interface**

On the ticket creation dialog, as soon as you select a template from the templates selection list, the *Body* field is filled in with that template content.

If the system configuration *Reference Attribute* is *Queue* (the default setting), the template list box contains only templates of the *Customer Create* type that are assigned to the selected queue for the ticket. The template selection list box is enabled only when a ticket queue is selected.

If the system configuration *Reference Attribute* is *Service*, the template list box contains only templates of the *Customer Create* type that are assigned to the selected service for the ticket. The template selection list box is enabled only when a ticket service is selected.

**Using Customer Templates to reply to tickets on the Customer interface**

If the system configuration *Reference Attribute* is *Queue* (the default setting), the template list box is provided only with templates of the *Customer Answer* type associated with the selected queue for the ticket.

If the system configuration *Reference Attribute* is *Service*, the template list box is provided only with templates of the *Customer Answer* type associated with the selected service for the ticket.

Further Reading
---------------
For those not yet familiar with the basics of the standard templates feature, a reference can be found `here <https://doc.otobo.de/manual/admin/10.1/en/content/ticket-settings/templates.html>`_.

Configuration
=============

System requirements
-------------------

Framework
^^^^^^^^^
OTOBO 11.1.x

Packages
^^^^^^^^
There are no package dependencies

Third-party software
^^^^^^^^^^^^^^^^^^^^
Not applicable

Basic Configuration
-------------------
#. Go to the Agent Interface Admin Overview
#. Select the Package Manager module from the Administration group
#. Select the package named CustomerTemplates from the Online Repository and click the associated  *Install* link on that line.
#. Respond affirmatively to any confirmation questions that may follow.

Custom Configuration and Advanced Features
------------------------------------------
**Setting the Reference Attribute**

By default, the Reference Attribute defaults to *Queue*. This means that on any of the Customer interface ticket dialogues, the template selection list box contains templates associated with the selected queue for the ticket. However, this configuration accepts *Queue* or *Service*. In the later case, on any of the Customer interface ticket dialogues, the template selection list box contains templates associated with the selected service for the ticket.

To set the Reference Attribute to *Queue* or *Service*, do as follows:

#. Go to the administration in Agent interface
#. Open the System Config module in the Administration group
#. Search and select the *CustomerTemplate::ReferenceAttribute* config option
#. On the selection list box which is given, select the intended attribute from the options *Queue* or *Service*.
#. Do not forget to deploy this change!

**Activating autoselection**

If autoselection is activated (it is deactivated by default), then when the template list box contains only one available item, that sole item is automatically selected and the template list box field is hidden.

To activate , do as follows:

#. Go to the administration in Agent interface
#. Open the System Config module in the Administration group
#. Search and select the *CustomerTemplate::Autoselect* config option
#. Enable and activate the checkbox that is given
#. Do not forget to deploy this change!

Configuration Reference
-----------------------

Core::Ticket
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CustomerTemplate::Autoselect
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Defines if a standard template should be automatically selected when it is the only one available.

CustomerTemplate::ReferenceAttribute
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Defines if the list of available standard templates depends on the queue or on the service.

StandardTemplate::CustomerTypes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Defines the list of customer types for templates.

Frontend::Admin::ModuleRegistration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Frontend::Module###AdminServiceTemplates
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the agent interface.

Frontend::Admin::ModuleRegistration::AdminOverview
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Frontend::NavigationModule###AdminServiceTemplates
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Admin area navigation for the agent interface.

Frontend::Admin::ModuleRegistration::Loader
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Loader::Module::AdminServiceTemplates###002-Ticket
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Frontend::Admin::ModuleRegistration::MainMenu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Frontend::Navigation###AdminServiceTemplates###002-Ticket
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Main menu item registration.

Frontend::Customer::ModuleRegistration::Loader
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Loader::Module::CustomerTicketMessage###003-StandardTemplates
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the customer interface.

Loader::Module::CustomerTicketZoom###003-StandardTemplates
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the customer interface.

About
=======

Contact
-------
| Rother OSS GmbH
| Email: hello@otobo.io
| Web: https://otobo.io

Version
-------
Author: |doc-vendor| / Version: |doc-version| / Date of release: |doc-datestamp|
