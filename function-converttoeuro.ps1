<#
.SYNOPSIS
   Converts Dollar to Euro
.DESCRIPTION
   Takes dollars and calculates the value in Euro by applying an exchange rate
.PARAMETER dollar
   the dollar amount. This parameter is mandatory.
.PARAMETER rate
   the exchange rate. The default value is set to 1.37.
.EXAMPLE
   ConvertTo-Euro 100
   converts 100 dollars using the default exchange rate and positional parameters
.EXAMPLE
   ConvertTo-Euro 100 -rate 2.3
   converts 100 dollars using a custom exchange rate
#>

function ConvertTo-Euro {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [double]
        $dollar,

        [Parameter(Mandatory=$false)]
        [double]
        $rate = 1.24,

        [switch]
        $pretty
    )
    begin {}

    process{   
        [double]$conversion = $dollar*$rate
        if ($pretty) {
            Write-Host "`$$dollar equals EUR$conversion at $rate rate"
        }
        else {
            $conversion    
        }    
    }
    
    end {}
}
####
##
#change3
#change4