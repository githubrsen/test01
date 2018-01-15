#TOLLE SACHE
#BLABLA_AENDERUNG
#BLABLA_AENDERUNG
#BLABLA_AENDERUNG
#BLABLA_AENDERUNG
<#
.SYNOPSIS
    Gets all the Active Directory groups that have a specified user, computer,
    group, or service account.
.DESCRIPTION
    Gets all the Active Directory groups that have a specified user, computer,
    group, or service account. Unlike the built-in Get-ADPrincipalGroupMembership
    cmtlet, the function I've provided below will perform a recursive search
    that will return all of the groups that the account is a member of through
    membership inheritance. This function required the Active Directory module
    and thus must be run on a domain controller or workstation with Remote Server
    Administration Tools.
.PARAMETER dsn
The distinguished name (dsn) of the user, computer, group, or service account.
.PARAMETER groups
An array of ADObject instances for each group in which the user, computer,
group, or service account is a member.  This parameter can be ignored and
in fact should never be specified by the caller. The groups parameter is
used internally to track groups that have already been added to the list
during recursive function calls.
.NOTES
    Author     : Brian Reich <breich@reich-consulting.net
.LINK
    http://www.reich-consulting.net
#>
function Get-ADPrincipalGroupMembershipRecursive( ) {
    Param(
        [string] $dsn,
        [array]$groups = @()
    )
    # Get an ADObject for the account and retrieve memberOf attribute.
    $obj = Get-ADObject $dsn -Properties memberOf
    # Iterate through each of the groups in the memberOf attribute.
    foreach( $groupDsn in $obj.memberOf ) {
        # Get an ADObject for the current group.
        $tmpGrp = Get-ADObject $groupDsn -Properties memberOf
        # Check if the group is already in $groups.
        if( ($groups | where { $_.DistinguishedName -eq $groupDsn }).Count -eq 0 ) {
            $groups +=  $tmpGrp 
            # Go a little deeper by searching this group for more groups.
            $groups = Get-ADPrincipalGroupMembershipRecursive $groupDsn $groups
        }
    }
    return $groups
}
# Simple Example of how to use the function
$username = Read-Host -Prompt "Enter a username"
$groups   = Get-ADPrincipalGroupMembershipRecursive (Get-ADUser $username).DistinguishedName
$groups | Sort-Object -Property name | Format-Table