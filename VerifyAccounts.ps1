Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

function Show-ValidatePasswordForm {
    param($DomainDefault)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Validate Password"
    $form.Size = New-Object System.Drawing.Size(400,250)
    $form.StartPosition = "CenterParent"

    $lblDomain = New-Object System.Windows.Forms.Label
    $lblDomain.Text = "Domain AD:"
    $lblDomain.Location = '-30,20'
    $lblDomain.TextAlign = 'MiddleRight'
    $form.Controls.Add($lblDomain)

    $txtDomain = New-Object System.Windows.Forms.TextBox
    $txtDomain.Location = '80,18'
    $txtDomain.Size = '280,20'
    $txtDomain.Text = $DomainDefault
    $form.Controls.Add($txtDomain)

    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Text = "Network User:"
    $lblUser.Location = '-22,55'
    $lblUser.TextAlign = 'MiddleRight'
    $form.Controls.Add($lblUser)

    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = '80,53'
    $txtUser.Size = '280,20'
    $form.Controls.Add($txtUser)

    $lblPass = New-Object System.Windows.Forms.Label
    $lblPass.Text = "Password:"
    $lblPass.Location = '-32,90'
    $lblPass.TextAlign = 'MiddleRight'
    $form.Controls.Add($lblPass)

    $txtPass = New-Object System.Windows.Forms.TextBox
    $txtPass.Location = '80,88'
    $txtPass.Size = '280,20'
    $txtPass.UseSystemPasswordChar = $false
    $form.Controls.Add($txtPass)

    $btnValidate = New-Object System.Windows.Forms.Button
    $btnValidate.Text = "Validate"
    $btnValidate.Location = '80,120'
    $form.Controls.Add($btnValidate)

    $lblResult = New-Object System.Windows.Forms.Label
    $lblResult.Location = '10,150'
    $lblResult.Size = '360,20'
    $form.Controls.Add($lblResult)

    $btnValidate.Add_Click({
        try {
            $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext `
                ([System.DirectoryServices.AccountManagement.ContextType]::Domain, $txtDomain.Text)
            if ($ctx.ValidateCredentials($txtUser.Text, $txtPass.Text)) {
                $lblResult.ForeColor = 'Green'
                $lblResult.Text = "Credenciais válidas."
            } else {
                $lblResult.ForeColor = 'Red'
                $lblResult.Text = "Credenciais inválidas."
            }
        } catch {
            $lblResult.ForeColor = 'Red'
            $lblResult.Text = "Erro: $($_.Exception.Message)"
        }
    })

    $form.ShowDialog()
}

function Set-Status {
    param($Label, $Text, $Color)
    $Label.Text = $Text
    $Label.ForeColor = $Color
}

$formMain = New-Object System.Windows.Forms.Form
$formMain.Text = "Verify Accounts AD"
$formMain.Size = New-Object System.Drawing.Size(720,350)
$formMain.StartPosition = "CenterScreen"

$lblDomain = New-Object System.Windows.Forms.Label
$lblDomain.Text = "Domain AD:"
$lblDomain.Location = '10,20'
$lblDomain.Size = '80,20'
$formMain.Controls.Add($lblDomain)

$txtDomain = New-Object System.Windows.Forms.TextBox
$txtDomain.Location = '100,18'
$txtDomain.Size = '350,20'
$txtDomain.Text = $env:USERDOMAIN
$formMain.Controls.Add($txtDomain)

$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = "Network User:"
$lblUser.Location = '10,55'
$lblUser.Size = '80,20'
$formMain.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = '100,53'
$txtUser.Size = '350,20'
$formMain.Controls.Add($txtUser)

$btnVerify = New-Object System.Windows.Forms.Button
$btnVerify.Text = "Verify User"
$btnVerify.Location = '100,85'
$btnVerify.Size = '110, 30'
$formMain.Controls.Add($btnVerify)

$btnValidatePwd = New-Object System.Windows.Forms.Button
$btnValidatePwd.Text = "Validate Password"
$btnValidatePwd.Location = '230,85'
$btnValidatePwd.Size = '110,30'
$formMain.Controls.Add($btnValidatePwd)

$lblStatusAccount   = New-Object System.Windows.Forms.Label
$lblStatusAccount.Location = '10,130'
$lblStatusAccount.Size = '450,20'
# $lblStatusAccount.Visible = $false
$formMain.Controls.Add($lblStatusAccount)

$lblStatusLock = New-Object System.Windows.Forms.Label
$lblStatusLock.Location = '10,160'
$lblStatusLock.Size = '450,20'
# $lblStatusAccount.Visible = $false
$formMain.Controls.Add($lblStatusLock)

$lblEmail = New-Object System.Windows.Forms.Label
$lblEmail.Location = '10,190'
$lblEmail.Size = '450,20'
$formMain.Controls.Add($lblEmail)

$lblPwdExpiry = New-Object System.Windows.Forms.Label
$lblPwdExpiry.Location = '10,220'
$lblPwdExpiry.Size = '450,20'
$formMain.Controls.Add($lblPwdExpiry)

$lblAccountExpiry = New-Object System.Windows.Forms.Label
$lblAccountExpiry.Location = '10,250'
$lblAccountExpiry.Size = '450,20'
$formMain.Controls.Add($lblAccountExpiry)

# Novo ListBox para grupos (no espaço vermelho da imagem)
$listGroups = New-Object System.Windows.Forms.ListBox
$listGroups.Location = '480,20'
$listGroups.Size = '200,250'
$formMain.Controls.Add($listGroups)

$btnVerify.Add_Click({
    $lblStatusAccount.Text = ""
    $lblStatusLock.Text = ""
    $lblEmail.Text = ""
    $lblPwdExpiry.Text = ""
    $lblAccountExpiry.Text = ""
    $listGroups.Items.Clear()

    try {
        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext `
            ([System.DirectoryServices.AccountManagement.ContextType]::Domain, $txtDomain.Text)
        $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($ctx, $txtUser.Text)

        if (-not $user) {
            [System.Windows.Forms.MessageBox]::Show("User not fount.", "Notice", 0, "Warning")
            return
        }

        # Conta ativa/desativada
        if ($user.Enabled) {
            Set-Status $lblStatusAccount "Conta Ativa" 'Green'
        } else {
            Set-Status $lblStatusAccount "Conta Desativada" 'Red'
        }

        # Conta bloqueada
        if ($user.IsAccountLockedOut()) {
            Set-Status $lblStatusLock "Conta Bloqueada" 'Red'
        } else {
            Set-Status $lblStatusLock "Conta Desbloqueada" 'Green'
        }

        # Email
        if ($user.EmailAddress) {
            Set-Status $lblEmail "E-mail: $($user.EmailAddress)" 'Green'
        } else {
            Set-Status $lblEmail "E-mail: (não definido)" 'Gray'
        }

        # Expiração da senha (90 dias corridos)
        $lastPwdSet = $user.LastPasswordSet
        if ($lastPwdSet) {
            $expiry = $lastPwdSet.AddDays(90)
            $daysLeft = ($expiry - (Get-Date)).TotalDays
            if ($daysLeft -gt 0) {
                Set-Status $lblPwdExpiry "Senha expira em $([math]::Floor($daysLeft)) dias" 'Green'
            } else {
                Set-Status $lblPwdExpiry "Senha expirada há $([math]::Abs([math]::Floor($daysLeft))) dias" 'Red'
            }
        } else {
            Set-Status $lblPwdExpiry "Senha nunca expira ou não calculável" 'Gray'
        }

        # Expiração da conta
        if ($user.AccountExpirationDate) {
            Set-Status $lblAccountExpiry "Conta expira em: $($user.AccountExpirationDate.ToUniversalTime()) (UTC)" 'Red'
        } else {
            Set-Status $lblAccountExpiry "Conta: Nunca expira" 'Green'
        }

        # Lista de grupos
        $groups = $user.GetGroups()
        foreach ($g in $groups) {
            $listGroups.Items.Add($g.Name)
        }

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erro: $($_.Exception.Message)", "Erro", 0, "Error")
    }
})

$btnValidatePwd.Add_Click({
    Show-ValidatePasswordForm $txtDomain.Text
})

[void]$formMain.ShowDialog()
