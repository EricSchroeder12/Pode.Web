Import-Module -Name Pode, Pode.Web
#Import-Module ActiveDirectory 
#Enter-PSSession TC-SVR-DC01.truebeck.com -Credential zeric.schroeder@truebeck.com

##Variables
#$$DC = "TC-SVR-DC01.Truebeck.com"


Start-PodeServer {
    Add-PodeEndpoint -Address 0.0.0.0 -Port 8082 -Protocol Http -Force

    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging -Levels @("Error", "Warning")

    Use-PodeWebTemplates -Title 'User Onboarding' -Theme Dark

    $navDiv = New-PodeWebNavDivider
    $navPode = New-PodeWebNavLink -Name 'Pode' -Url 'https://badgerati.github.io/Pode/' -Icon 'server' -NewTab
    $navPodeWeb = New-PodeWebNavLink -Name 'PodeWeb' -Url 'https://badgerati.github.io/Pode.Web/' -Icon 'web-check' -NewTab
    $navGH = New-PodeWebNavLink -name 'GitHub' -Url 'https://github.com/EricSchroeder12' -Icon 'github' -NewTab
    $navPwpush = New-PodeWebNavLink -name 'PwPush' -Url 'https://pwpush.com/' -Icon 'lock-check' -NewTab
    $navSupport = New-PodeWebNavLink -Name 'Support' -Url 'https://evolutionitservice.com/contact-us/' -Icon 'web-check' -NewTab

    Set-PodeWebNavDefault -Items $navPode, $navDiv, $navPodeWeb, $navDiv, $navGH, $navDiv, $navPwpush, $navDiv, $navSupport

    Add-PodeWebPage -Name 'Onboarding' -NoTitle -ScriptBlock {
        New-PodeWebContainer -Content @(
            New-PodeWebForm -Name 'Onboardingform' -SubmitText "Generate" -ShowReset -ResetText "Reset form" -Content @(
                New-PodeWebTextbox -Name "Enter in the User's First Name"
                New-PodeWebTextbox -Name "Enter in the User's Last Name"
                New-PodeWebTextbox -Name "Enter in the User's Job Title"
                #New-PodeWebSelect -Name 'Baseline Security Group'
                    #-ScriptBlock { 
                     #   [array]$DropDownArrayItems = @("")
                      #  [array]$DropDownArrayItems += (Get-ADGroup -Server $DC -Filter * -Properties Name).NAME
                       # [array]$DropDownArray = $DropDownArrayItems | sort
                    #}
                New-PodeWebTextBox -Name  
                #New-PodeWebTextbox -Name "secret" -DisplayName "Password"
                #New-PodeWebTextbox -Name "Password link" -ReadOnly
                New-PodeWebButton -Name "Push password" -CssStyle @{"margin-bottom" = "0rem"} -ScriptBlock {
                    if ( [string]::IsNullOrEmpty($WebEvent.Data.secret))
                    {
                        Show-PodeWebToast -Message "Password field cannot be empty" -Title "Error" -Icon "alert-circle"
                        return
                    }       
                    $link = Submit-Password -text $WebEvent.Data.secret
                    Update-PodeWebTextbox -Value $link -Name "Password link"
                }
            ) -ScriptBlock {
                
                if (!$WebEvent.Data.Options)
                {
                    Show-PodeWebToast -Message "You must select at least one option" -Title "Error"
                }
                else
                {
                    $np = New-Password -Data $WebEvent.Data
                    Update-PodeWebTextbox -Value $np -Name "secret"
                }
            }
        )
    }
    Add-PodeWebPage -Name 'Password Generator' -NoTitle -ScriptBlock {
        New-PodeWebContainer -Content @(
            New-PodeWebForm -Name 'Onboardingform' -SubmitText "Generate" -ShowReset -ResetText "Reset form" -Content @(
                New-PodeWebRange -Name 'Length' -Min 12 -Max 100 -ShowValue -Value 30
                New-PodeWebCheckbox -Name 'Options' -Options @("upper", "lower", "numeric", "special") -DisplayOptions @("A-Z", "a-z", "0-9", "@#^&$")
                New-PodeWebTextbox -Name "secret" -DisplayName "Password"
                New-PodeWebTextbox -Name "Password link" -ReadOnly
                New-PodeWebButton -Name "Push password" -CssStyle @{"margin-bottom" = "0rem"} -ScriptBlock {
                    if ( [string]::IsNullOrEmpty($WebEvent.Data.secret))
                    {
                        Show-PodeWebToast -Message "Password field cannot be empty" -Title "Error" -Icon "alert-circle"
                        return
                    }       
                    $link = Submit-Password -text $WebEvent.Data.secret
                    Update-PodeWebTextbox -Value $link -Name "Password link"
                }
            ) -ScriptBlock {
                
                if (!$WebEvent.Data.Options)
                {
                    Show-PodeWebToast -Message "You must select at least one option" -Title "Error"
                }
                else
                {
                    $np = New-Password -Data $WebEvent.Data
                    Update-PodeWebTextbox -Value $np -Name "secret"
                }
            }
        )
    } 
}