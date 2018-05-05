function Get-InstalledSoftware {
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
        $SelectParams = @{ #3 default parameters passed to Select-Object at the end as a hash table
            Property = 'DisplayName', 'InstallLocation', 'InstallDate'}
        
        switch ($PSBoundParameters.Keys) { #switch to detect the presence of $first function parameter rather than using an IF block.
            'First' {
                $SelectParams['First'] = $first
            }
            'Skip' { #not sure if need Skip and Unique
                $SelectParams['Skip'] = $Skip
            }
            'Unique' {
                $SelectParams['Unique'] = $true
            }
        }
        $paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $PrevErrorActionPreference = $ErrorActionPreference  #hides errors on $null $_.InstallDate's. Could alternatively add IF block inside foreach-object
        $ErrorActionPreference = 'SilentlyContinue'
        $keysfiltered = Get-ItemProperty -Path $paths | 
            Where-Object {$_.DisplayName -like "*$name*"} | 
            Select-Object DisplayName, InstallLocation, @{
                n = 'InstallDate';
                e = {
                    [datetime]::ParseExact($_.InstallDate, "yyyyMMdd", [System.Globalization.CultureInfo]::InvariantCulture)
                }
            } |
            Where-Object {$_.InstallDate -ge $date} |
            Select-Object @SelectParams
        $ErrorActionPreference = $PrevErrorActionPreference


        $keysfiltered | Format-Table -AutoSize
        $keyssubtotal = (Get-ItemProperty -Path $paths).count #total number of reg keys with property values in $paths
        $keystotal = (Get-Item -Path $paths).count #total number of reg keys in $paths
        Write-Host -BackgroundColor Black -ForegroundColor Blue "
        Your search returned  $($keysfiltered.count)  installed piece(s) of software out of a total of  $keyssubtotal. For referenence there 
        are  $keystotal registry keys in your uninstall path, but not all represent installed software. `n"   
    }
    end {}
}
