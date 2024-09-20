# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.io/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package Kernel::Modules::AdminServiceTemplates;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    if ( !$Param{AccessRw} && $Param{AccessRo} ) {
        $Self->{LightAdmin} = 1;
    }

    return $Self;
}

use Data::Dumper;

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject            = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject           = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ServiceObject            = $Kernel::OM->Get('Kernel::System::Service');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');

    # ------------------------------------------------------------ #
    # template <-> services 1:n
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Template' ) {

        # get template data
        my $ID                   = $ParamObject->GetParam( Param => 'ID' );
        my %StandardTemplateData = $StandardTemplateObject->StandardTemplateGet( ID => $ID );

        # get services
        my %ServiceData = $ServiceObject->ServiceList( 
            Valid => 1,
            UserID => $Self->{UserID},
        );

        # get assigned services
        my %Member = $ServiceObject->ServiceStandardTemplateMemberList(
            StandardTemplateID => $ID,
        );

        my $StandardTemplateType = $LayoutObject->{LanguageObject}->Translate(
            $StandardTemplateData{TemplateType},
        );

        if ( $Self->{LightAdmin} ) {

            # Filter out services without permission.
            my %RwServices = $ServiceObject->GetAllServices(
                UserID => $Self->{UserID},
                Type   => 'rw',
            );

            for my $ServiceID ( keys %ServiceData ) {
                delete $ServiceData{$ServiceID} if !$RwServices{$ServiceID};
            }

            # Check the permission.
            my %Services     = $ServiceObject->ServiceStandardTemplateMemberList( StandardTemplateID => $ID );
            my $Permission = $ServiceObject->ServiceListPermission(
                ServiceIDs => [ keys %Services ],
                UserID   => $Self->{UserID},
                Default  => 'rw',
            );

            if ( $Permission ne 'rw' ) {
                undef %StandardTemplateData;
                undef %Member;
                $StandardTemplateType = '';
            }
        }

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_Change(
            Selected => \%Member,
            Data     => \%ServiceData,
            ID       => $StandardTemplateData{ID},
            Name     => $StandardTemplateType . ' - ' . $StandardTemplateData{Name},
            Type     => 'Template',
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # templates <-> Service n:1
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Service' ) {

        # get service data
        my $ID        = $ParamObject->GetParam( Param => 'ID' );
        my %ServiceData = $ServiceObject->ServiceGet( 
            ServiceID => $ID,
            UserID => $Self->{UserID},
        );

        # get templates
        my %StandardTemplateData = $StandardTemplateObject->StandardTemplateList(
            Valid => 1,
        );

        if (%StandardTemplateData) {
            for my $StandardTemplateID ( sort keys %StandardTemplateData ) {
                my %Data = $StandardTemplateObject->StandardTemplateGet(
                    ID => $StandardTemplateID
                );
                $StandardTemplateData{$StandardTemplateID} = $LayoutObject->{LanguageObject}->Translate( $Data{TemplateType} )
                    . ' - '
                    . $Data{Name};
            }
        }

        # get assigned templates
        my %Member = $ServiceObject->ServiceStandardTemplateMemberList(
            ServiceID => $ID,
        );

        if ( $Self->{LightAdmin} ) {

            # Filter out templates without permission.
            for my $StandardTemplateID ( keys %StandardTemplateData ) {
                my %Services     = $ServiceObject->ServiceStandardTemplateMemberList( StandardTemplateID => $StandardTemplateID );
                my $Permission = $ServiceObject->ServiceListPermission(
                    ServiceIDs => [ keys %Services ],
                    UserID   => $Self->{UserID},
                    Default  => 'rw',
                );
                if ( $Permission ne 'rw' ) {
                    delete $StandardTemplateData{$StandardTemplateID};
                }
            }

            # Check the permission.
            my %RwServices = $ServiceObject->GetAllServices(
                UserID => $Self->{UserID},
                Type   => 'rw',
            );

            if ( !$RwServices{$ID} ) {
                undef %ServiceData;
                undef %Member;
            }
        }

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_Change(
            Selected => \%Member,
            Data     => \%StandardTemplateData,
            ID       => $ServiceData{ServiceID},
            Name     => $ServiceData{Name},
            Type     => 'Service',
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add templates to service
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeService' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get new templates
        my @TemplatesSelected = $ParamObject->GetArray( Param => 'ItemsSelected' );
        my @TemplatesAll      = $ParamObject->GetArray( Param => 'ItemsAll' );

        my $ServiceID = $ParamObject->GetParam( Param => 'ID' );

        # create hash with selected templates
        my %TemplatesSelected = map { $_ => 1 } @TemplatesSelected;

        if ( $Self->{LightAdmin} ) {
            ID:
            for my $StandardTemplateID ( keys %TemplatesSelected ) {
                next ID if !$StandardTemplateID;    # Can contain empty string.

                my %Services     = $ServiceObject->ServiceStandardTemplateMemberList( StandardTemplateID => $StandardTemplateID );
                my $Permission = $ServiceObject->ServiceListPermission(
                    ServiceIDs => [ keys %Services ],
                    UserID   => $Self->{UserID},
                    Default  => 'rw',
                );
                if ( $Permission ne 'rw' ) {
                    return $LayoutObject->Redirect(
                        OP => "Action=$Self->{Action}"
                    );
                }
            }
        }

        # check all used templates
        for my $TemplateID (@TemplatesAll) {
            my $Active = $TemplatesSelected{$TemplateID} ? 1 : 0;

            # set customer user service member
            $ServiceObject->ServiceStandardTemplateMemberAdd(
                ServiceID            => $ServiceID,
                StandardTemplateID => $TemplateID,
                Active             => $Active,
                UserID             => $Self->{UserID},
            );
        }

        # if the user would like to continue editing the templates - service relation just redirect to the edit screen
        # otherwise return to relations overview
        if (
            defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
            && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
            )
        {
            return $LayoutObject->Redirect(
                OP => "Action=$Self->{Action};Subaction=Service;ID=$ServiceID"
            );
        }
        else {
            return $LayoutObject->Redirect(
                OP => "Action=$Self->{Action}"
            );
        }
    }

    # ------------------------------------------------------------ #
    # add services to template
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeTemplate' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get new services
        my @ServicesSelected = $ParamObject->GetArray( Param => 'ItemsSelected' );
        my @ServicesAll      = $ParamObject->GetArray( Param => 'ItemsAll' );

        my $TemplateID = $ParamObject->GetParam( Param => 'ID' );

        # create hash with selected services
        my %ServicesSelected = map { $_ => 1 } @ServicesSelected;

        # backend check to prevent saving without permission.
        if ( $Self->{LightAdmin} ) {
            my %RwServices = $ServiceObject->GetAllServices(
                UserID => $Self->{UserID},
                Type   => 'rw',
            );
            ID:
            for my $ServiceID ( keys %ServicesSelected ) {
                next ID if !$ServiceID;    # Can contain empty string.
                if ( !$RwServices{$ServiceID} ) {
                    return $LayoutObject->Redirect(
                        OP => "Action=$Self->{Action}"
                    );
                }
            }
        }

        # check all used services
        for my $ServiceID (@ServicesAll) {
            my $Active = $ServicesSelected{$ServiceID} ? 1 : 0;

            # set customer user service member
            $ServiceObject->ServiceStandardTemplateMemberAdd(
                ServiceID            => $ServiceID,
                StandardTemplateID => $TemplateID,
                Active             => $Active,
                UserID             => $Self->{UserID},
            );
        }

        # if the user would like to continue editing the service - templates relation just redirect to the edit screen
        # otherwise return to relations overview
        if (
            defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
            && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
            )
        {
            return $LayoutObject->Redirect(
                OP => "Action=$Self->{Action};Subaction=Template;ID=$TemplateID"
            );
        }
        else {
            return $LayoutObject->Redirect(
                OP => "Action=$Self->{Action}"
            );
        }
    }

    # ------------------------------------------------------------ #
    # overview
    # ------------------------------------------------------------ #
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $Self->_Overview();
    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my %Data   = %{ $Param{Data} };
    my $Type   = $Param{Type} || 'Template';
    my $NeType = $Type eq 'Service' ? 'Template' : 'Service';

    my %VisibleType = (
        Template => 'Template',
        Service    => 'Service',
    );

    my $MyType       = $VisibleType{$Type};
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $BreadcrumbTitle = $LayoutObject->{LanguageObject}->Translate('Change Service Relations for Template');

    if ( $VisibleType{$Type} eq 'Service' ) {
        $BreadcrumbTitle = $LayoutObject->{LanguageObject}->Translate('Change Template Relations for Service');
    }

    $LayoutObject->Block(
        Name => 'Overview',
        Data => {
            Name            => $Param{Name},
            BreadcrumbTitle => $BreadcrumbTitle,
        },
    );
    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );
    $LayoutObject->Block( Name => 'Filter' );

    #fixed link
    my $ServiceTag;

    $ServiceTag = $Type eq 'Service' ? 'Service' : '';

    $LayoutObject->Block(
        Name => 'Change',
        Data => {
            %Param,
            ActionHome      => 'Admin' . $Type,
            NeType          => $NeType,
            VisibleType     => $VisibleType{$Type},
            VisibleNeType   => $VisibleType{$NeType},
            Service           => $ServiceTag,
            BreadcrumbTitle => $BreadcrumbTitle,
        },
    );

    # check if there are service/template
    if ( !%Data ) {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsgList',
            Data => {
                ColSpan => 2,
            },
        );
    }

    $LayoutObject->Block(
        Name => 'ChangeHeader',
        Data => {
            %Param,
            Type          => $Type,
            NeType        => $NeType,
            VisibleType   => $VisibleType{$Type},
            VisibleNeType => $VisibleType{$NeType},
        },
    );

    for my $ID ( sort { uc( $Data{$a} ) cmp uc( $Data{$b} ) } keys %Data ) {

        # set output class
        my $Selected = $Param{Selected}->{$ID} ? ' checked ' : '';

        $ServiceTag = $Type ne 'Service' ? 'Service' : '';

        $LayoutObject->Block(
            Name => 'ChangeRow',
            Data => {
                %Param,
                Name          => $Param{Data}->{$ID},
                NeType        => $NeType,
                Type          => $Type,
                ID            => $ID,
                Selected      => $Selected,
                VisibleType   => $VisibleType{$Type},
                VisibleNeType => $VisibleType{$NeType},
                Service         => $ServiceTag,
            },
        );
    }

    return $LayoutObject->Output(
        TemplateFile => 'AdminServiceTemplates',
        Data         => \%Param,
        VisibleType  => $MyType,
    );
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ServiceObject  = $Kernel::OM->Get('Kernel::System::Service');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => {},
    );

    # no actions in action list
    #    $LayoutObject->Block(Name=>'ActionList');
    $LayoutObject->Block( Name => 'FilterTemplate' );
    $LayoutObject->Block( Name => 'FilterService' );
    $LayoutObject->Block( Name => 'OverviewResult' );

    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');

    # get std template list
    my %StandardTemplateData = $StandardTemplateObject->StandardTemplateList(
        Valid => 1,
    );

    # if there are results to show
    if (%StandardTemplateData) {
        for my $StandardTemplateID ( sort keys %StandardTemplateData ) {
            my %Data = $StandardTemplateObject->StandardTemplateGet(
                ID => $StandardTemplateID,
            );
            $StandardTemplateData{$StandardTemplateID} = $LayoutObject->{LanguageObject}->Translate( $Data{TemplateType} )
                . ' - '
                . $Data{Name};
        }
        ID:
        for my $StandardTemplateID (
            sort { uc( $StandardTemplateData{$a} ) cmp uc( $StandardTemplateData{$b} ) }
            keys %StandardTemplateData
            )
        {
            if ( $Self->{LightAdmin} ) {
                my %Services     = $ServiceObject->ServiceStandardTemplateMemberList( StandardTemplateID => $StandardTemplateID );
                my $Permission = $ServiceObject->ServiceListPermission(
                    ServiceIDs => [ keys %Services ],
                    UserID   => $Self->{UserID},
                    Default  => 'rw',
                );
                if ( $Permission ne 'rw' ) {
                    next ID;
                }
            }

            # set output class
            $LayoutObject->Block(
                Name => 'List1n',
                Data => {
                    Name      => $StandardTemplateData{$StandardTemplateID},
                    Subaction => 'Template',
                    ID        => $StandardTemplateID,
                },
            );
        }
    }

    # otherwise it displays a no data found message
    else {
        $LayoutObject->Block(
            Name => 'NoTemplatesFoundMsg',
            Data => {},
        );
    }

    # get service data
    my %ServiceData = $Kernel::OM->Get('Kernel::System::Service')->ServiceList( Valid => 1, UserID => $Self->{UserID} );

    if ( $Self->{LightAdmin} ) {

        # Filter out services without permission.
        my %RwServices = $ServiceObject->GetAllServices(
            UserID => $Self->{UserID},
            Type   => 'rw',
        );

        for my $ServiceID ( keys %ServiceData ) {
            delete $ServiceData{$ServiceID} if !$RwServices{$ServiceID};
        }
    }

    # if there are results to show
    if (%ServiceData) {
        for my $ServiceID ( sort { uc( $ServiceData{$a} ) cmp uc( $ServiceData{$b} ) } keys %ServiceData ) {

            # set output class
            $LayoutObject->Block(
                Name => 'Listn1',
                Data => {
                    Name      => $ServiceData{$ServiceID},
                    Subaction => 'Service',
                    ID        => $ServiceID,
                },
            );
        }
    }

    # otherwise it displays a no data found message
    else {
        $LayoutObject->Block(
            Name => 'NoServicesFoundMsg',
            Data => {},
        );
    }

    # return output
    return $LayoutObject->Output(
        TemplateFile => 'AdminServiceTemplates',
        Data         => \%Param,
    );
}

1;
