<#
1) Get-Item -Path $paths - gets all keys
2) Get-ItemProperty -Path $paths = Get-Item -Path $paths | where {$_.property} - includes (Default) "" or "**" but not value not set/$null
3) Get-Item -Path $paths | Where {$_.property -contains "(default)"} - gets all keys with only the '(Default)' property with data entered 
    e.g. KB2151757 or "" (empty string), exludes (value not set)
4) *Can do (Get-Item -Path $paths).getvalue("InstallDate") instead of get-itemproperty ||  Get-Item -Path $paths | ForEach-Object {$_.getvalue("installdate")}*
    Get-Item -Path $paths | Select-Object  @{l = 'path'; e = {$_.pspath}}, @{l = 'date'; e = {$_.getvalue("installdate")}} - returns all keys 
5) Some apps have no uninstallstring but have displayname - | where {$_.Valuecount -eq 1 -and ($_.property -notcontains "(default)")}
6) Some apps with no uninstallstring have installlocation's - Get-Item -Path $paths | where {$_.property -notcontains "UninstallString"}
#>

#add functionality for -first
#add sorting functionality
function Get-InstallSoftware2 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]
        $name,

        [Parameter(Mandatory=$false)]
        [int]
        $first,

        [Parameter(Mandatory=$false)]
        [datetime]
        $date
    )
    begin {}
    process {
        $paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $keys = get-item -Path $paths | 
                    Where-Object {$_.getvalue('displayname') -like "*$name*" <#-or ($_.getvalue('displayname') -eq $null)#>} |
                    ForEach-Object {
                        $newObject = [PSCustomObject]@{
                            'Display Name' = if($_.getvalue('displayname')) {$_.getvalue('displayname')} else {$_.name.substring($_.name.LastIndexOf('\')+1)}
                            'Install Location' = if($_.getvalue('installlocation')) {$_.getvalue('installlocation')} else {'NoPath'}
                            'Original Install Date' = if ($_.getvalue('installdate')) {[datetime]::ParseExact($_.getvalue('installdate'), 'yyyyMMdd', $null)} else {'NoDate'}
                            'Uninstall String' = if ($_.getvalue('uninstallstring')) {$_.getvalue('uninstallstring')} else {'NA'}
                        }
                        $newObject
                    } | Where-Object {$_.'Original Install Date' -ge $date}
       $keys
       $keys.count
        
    }
    end {}
}