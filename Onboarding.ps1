    ##User and Group Manager for Truebeck Construction
        ##Created by Eric Schroeder 12/1/2022
        ##Evolution IT Services 
            #Issue with not being able to write to AD https://www.easy365manager.com/enter-pssession-connecting-to-remote-server-failed/#:~:text=The%20error%20message%20means%20that,proper%20permissions%20on%20System%20B.
                #MVP Notes
                ##1. Onboarding 
                    ## Cell Phone addition
                ##2. Offbaording - Search for user and it will send to Terminated OU for processing
                ##3. PWPush


Import-Module -Name Pode, Pode.Web
Import-Module ActiveDirectory 
Import-Module -Name "C:\Users\Eric\Documents\GitHub Repos\Pode.Web\password.ps1" #Needed for the Passsword Generator. File needs to be copied to the docker image!
#Enter-PSSession TC-SVR-DC01.truebeck.com -Credential zeric.schroeder@truebeck.com


##Variables
$DC = "TC-SVR-DC01.Truebeck.com"
#$creds = Get-Credential
$creds = "truebeck\zeric.schroeder"

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

    Add-PodeWebPage -Name 'Onboarding'  -ScriptBlock {
        New-PodeWebContainer  -Content @(
            New-PodeWebForm -Name 'Onboardingform' -SubmitText "Generate" -ShowReset -ResetText "Reset form" -Content @(
                New-PodeWebCard -Content @(
                New-PodeWebForm -Name 'AdminCreds' -ScriptBlock {
                    $username = $WebEvent.Data['Creds_Username']
                    $password = $WebEvent.Data['Creds_Password']
                } -Content @(
                New-PodeWebCredential -Name 'Enter in your Admin Credentials'
            )
        )   
                
                New-PodeWebTextbox -Name "Enter in the User's First Name"
                New-PodeWebTextbox -Name "Enter in the User's Last Name"
                New-PodeWebTextbox -Name "Enter in the User's Job Title"
                New-PodeWebCard -Name 'Job Title' -Content @(
                        New-PodeWebForm -Name 'Job Title' -ScriptBlock {
                            $single = $WebEvent.Data['Job Title']
                        } -Content @(
                            New-PodeWebSelect -Name 'Job Title' -Options 'Select Job Title', 'Cost Engineer', 'Foreman', 'Intern', 'Marketing', 'Project Coordinator', 'Project Engineer','Project Manager', 'Project Executive','Sr. Project Coordinator','Sr. Project Engineer', 'Sr. Project Executive', 'Sr. Project Manager' ,'Superintendent' -SelectedValue 'Select Job Title'
                        )
                    )
                     
                New-PodeWebCard -Name 'Baseline Security Group' -Content @(
                        New-PodeWebForm -Name 'Baseline Security Group' -ScriptBlock {
                            $BaseSecGroup = $WebEvent.Data['BaseSecGroup']
                            
                        } -Content @(
                            New-PodeWebSelect -Name 'BaseSecGroup' -ScriptBlock { Enter-PSSession -ComputerName TC-SVR-DC01.truebeck.com -Credential "truebeck\zeric.schroeder"| Get-ADGroup -Credential "truebeck\zeric.schroeder" -Server TC-SVR-DC01.Truebeck.com -Filter * | select SamAccountName}
                                                     
                        )
                         
                    )
                                    
                    #$pdx = Submit-Password -text $WebEvent.Data.pdx
                New-PodeWebCard -Name 'PDX Office?' -Content @(
                        New-PodeWebForm -Name 'PDX?' -ScriptBlock {
                            $bestLang = $WebEvent.Data['Will the user be in the PDX Office?']
                        } -Content @(
                            New-PodeWebRadio -Name 'Will the user be in the PDX Office?' -Options 'No', 'Yes'
                        )
                    )
                           
             
                New-PodeWebTextbox -Name "secret" -DisplayName "Password" 
                                
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

    Add-PodeWebPage -Name 'Offboarding' -NoTitle -ScriptBlock {
        
            
        
    }
}
    
