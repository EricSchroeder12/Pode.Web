Import-Module Pode -MaximumVersion 2.99.99 -Force
Import-Module ..\src\Pode.Web.psm1 -Force

Start-PodeServer {
    # add a simple endpoint
    Add-PodeEndpoint -Address localhost -Port 8090 -Protocol Http
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging


    # enable sessions and authentication
    Enable-PodeSessionMiddleware -Secret 'schwifty' -Duration (10 * 60) -Extend

    New-PodeAuthScheme -Form | Add-PodeAuth -Name Example -ScriptBlock {
        param($username, $password)

        # here you'd check a real user storage, this is just for example
        if ($username -eq 'morty' -and $password -eq 'pickle') {
            return @{
                User = @{
                    ID ='M0R7Y302'
                    Name = 'Morty'
                    Type = 'Human'
                }
            }
        }

        return @{ Message = 'Invalid details supplied' }
    }


    # set the use of templates, and set a login page
    Use-PodeWebTemplates -Title Test
    Set-PodeWebLoginPage -Authentication Example


    # set the home page controls (just a simple paragraph) [note: homepage does not require auth in this example]
    $section = New-PodeWebSection -Name 'Welcome' -NoHeader -Controls @(
        New-PodeWebParagraph -Value 'This is an example homepage, with some example text'
        New-PodeWebParagraph -Value 'Using some example paragraphs'
    )
    Set-PodeWebHomePage -NoAuth -Components $section -Title 'Awesome Homepage'


    # add a page to search and filter services (output in a new table component) [note: requires auth]
    $table = New-PodeWebTable -Name 'Results' -Id 'tbl_svc_results'
    $form = New-PodeWebForm -Name 'Search' -ScriptBlock {
        param($Name)
        $svcs = @(Get-Service -Name $Name -ErrorAction Ignore | Select-Object Name, Status)
        $svcs | Out-PodeWebTable -Id 'tbl_svc_results'
        Show-PodeWebToast -Message "Found $($svcs.Length) services"
    } -Controls @(
        New-PodeWebTextbox -Name 'Name'
    )

    Add-PodeWebPage -Name Services -Icon Settings -Components $form, $table


    # add a page to search process (output as json in an appended textbox) [note: requires auth]
    $form = New-PodeWebForm -Name 'Search' -ScriptBlock {
        param($Name)
        Get-Process -Name $Name -ErrorAction Ignore | Select-Object Name, ID, WorkingSet, CPU | Out-PodeWebTextbox -Multiline -Preformat -AsJson
    } -Controls @(
        New-PodeWebTextbox -Name 'Name'
    )

    Add-PodeWebPage -Name Processes -Icon Activity -Components $form
}