Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

#-----------------------------------------------------------
# FORM VALIDAR SENHA
#-----------------------------------------------------------
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

#-----------------------------------------------------------
# FORM ALTERAR SENHA
#-----------------------------------------------------------
function Show-ChangePasswordForm {
    param($DomainDefault)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Change Password"
    $form.Size = New-Object System.Drawing.Size(400,250)
    $form.StartPosition = "CenterParent"

    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Text = "User:"
    $lblUser.Location = '20,20'
    $form.Controls.Add($lblUser)

    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = '150,18'
    $txtUser.Size = '200,20'
    $form.Controls.Add($txtUser)

    $lblOldPass = New-Object System.Windows.Forms.Label
    $lblOldPass.Text = "Old password:"
    $lblOldPass.Location = '20,60'
    $form.Controls.Add($lblOldPass)

    $txtOldPass = New-Object System.Windows.Forms.TextBox
    $txtOldPass.Location = '150,58'
    $txtOldPass.Size = '200,20'
    $txtOldPass.UseSystemPasswordChar = $true
    $form.Controls.Add($txtOldPass)

    $lblNewPass = New-Object System.Windows.Forms.Label
    $lblNewPass.Text = "New password:"
    $lblNewPass.Location = '20,100'
    $form.Controls.Add($lblNewPass)

    $txtNewPass = New-Object System.Windows.Forms.TextBox
    $txtNewPass.Location = '150,98'
    $txtNewPass.Size = '200,20'
    $txtNewPass.UseSystemPasswordChar = $true
    $form.Controls.Add($txtNewPass)

    $btnConfirm = New-Object System.Windows.Forms.Button
    $btnConfirm.Text = "Modify"
    $btnConfirm.Location = '150,150'
    $form.Controls.Add($btnConfirm)

    $btnConfirm.Add_Click({
        try {
            $user = $txtUser.Text
            $oldPass = (ConvertTo-SecureString $txtOldPass.Text -AsPlainText -Force)
            $newPass = (ConvertTo-SecureString $txtNewPass.Text -AsPlainText -Force)

            $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Domain',$DomainDefault)

            if ($ctx.ValidateCredentials($user, $txtOldPass.Text)) {
                Set-ADAccountPassword -Identity $user -OldPassword $oldPass -NewPassword $newPass -Server $DomainDefault -ErrorAction Stop
                [System.Windows.Forms.MessageBox]::Show("Password changed successfully!","successfully")
                $form.Close()
            } else {
                [System.Windows.Forms.MessageBox]::Show("Incorrect old password","Error")
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Faild to changing password: $($_.Exception.Message)","Error")
        }
    })

    $form.ShowDialog()
}

#-----------------------------------------------------------
# FUNÇÃO STATUS
#-----------------------------------------------------------
function Set-Status {
    param($Label, $Text, $Color)
    $Label.Text = $Text
    $Label.ForeColor = $Color
}

#-----------------------------------------------------------
# FORM PRINCIPAL
#-----------------------------------------------------------
$formMain = New-Object System.Windows.Forms.Form
$formMain.Text = "Verify Accounts AD - By Kevin Stone"
$formMain.Size = New-Object System.Drawing.Size(800,380)
$formMain.StartPosition = "CenterScreen"

$lblDomain = New-Object System.Windows.Forms.Label
$lblDomain.Text = "Domain AD:"
$lblDomain.Location = '10,20'
$lblDomain.Size = '80,20'
$formMain.Controls.Add($lblDomain)

$txtDomain = New-Object System.Windows.Forms.TextBox
$txtDomain.Location = '100,20'
$txtDomain.Size = '430,20'
$txtDomain.Text = $env:USERDOMAIN
$formMain.Controls.Add($txtDomain)

$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = "Network User:"
$lblUser.Location = '10,55'
$lblUser.Size = '80,20'
$formMain.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = '100,53'
$txtUser.Size = '430,20'
$formMain.Controls.Add($txtUser)

$btnVerify = New-Object System.Windows.Forms.Button
$btnVerify.Text = "Verify User"
$btnVerify.Location = '100,85'
$btnVerify.Size = '100, 30'
$formMain.Controls.Add($btnVerify)

$btnValidatePwd = New-Object System.Windows.Forms.Button
$btnValidatePwd.Text = "Check Password"
$btnValidatePwd.Location = '210,85'
$btnValidatePwd.Size = '100,30'
$formMain.Controls.Add($btnValidatePwd)

$btnChangePass = New-Object System.Windows.Forms.Button
$btnChangePass.Text = "Reset Password"
$btnChangePass.Location = '320,85'
$btnChangePass.Size = '100,30'
$formMain.Controls.Add($btnChangePass)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear"
$btnClear.Location = '430,85'
$btnClear.Size = '100,30'
$formMain.Controls.Add($btnClear)

$btnClear.Add_Click({
    $txtUser.Clear()
    $lblDisplayName.Text = ""
    $lblStatusAccount.Text = ""
    $lblStatusLock.Text = ""
    $lblEmail.Text = ""
    $lblPwdExpiry.Text = ""
    $lblAccountExpiry.Text = ""
    $listGroups.Items.Clear()
    $txtOU.Clear()
})

$btnChangePass.Add_Click({
    Show-ChangePasswordForm $txtDomain.Text
})

#-----------------------------------------------------------
# CAMPOS DE RESULTADO
#-----------------------------------------------------------
$txtOU = New-Object System.Windows.Forms.TextBox
$txtOU.Location = '10,310'
$txtOU.Size = '525,20'
$txtOU.ReadOnly = $true
$txtOU.BackColor = 'LightBlue'
$formMain.Controls.Add($txtOU)

# Novo campo: Display Name
$lblDisplayName = New-Object System.Windows.Forms.Label
$lblDisplayName.Location = '10,130'
$lblDisplayName.Size = '450,20'
$formMain.Controls.Add($lblDisplayName)

$lblStatusAccount   = New-Object System.Windows.Forms.Label
$lblStatusAccount.Location = '10,160'
$lblStatusAccount.Size = '450,20'
$formMain.Controls.Add($lblStatusAccount)

$lblStatusLock = New-Object System.Windows.Forms.Label
$lblStatusLock.Location = '10,190'
$lblStatusLock.Size = '450,20'
$formMain.Controls.Add($lblStatusLock)

$lblEmail = New-Object System.Windows.Forms.Label
$lblEmail.Location = '10,220'
$lblEmail.Size = '450,20'
$formMain.Controls.Add($lblEmail)

$lblPwdExpiry = New-Object System.Windows.Forms.Label
$lblPwdExpiry.Location = '10,250'
$lblPwdExpiry.Size = '450,20'
$formMain.Controls.Add($lblPwdExpiry)

$lblAccountExpiry = New-Object System.Windows.Forms.Label
$lblAccountExpiry.Location = '10,280'
$lblAccountExpiry.Size = '450,20'
$formMain.Controls.Add($lblAccountExpiry)

$listGroups = New-Object System.Windows.Forms.ListBox
$listGroups.Location = '550,18'
$listGroups.Size = '200,280'
$formMain.Controls.Add($listGroups)

#-----------------------------------------------------------
# EVENTOS
#-----------------------------------------------------------
$btnVerify.Add_Click({
    $lblDisplayName.Text = ""
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
            [System.Windows.Forms.MessageBox]::Show("User not found.", "Notice", 0, "Warning")
            return
        }

        # Display Name
        if ($user.DisplayName) {
            Set-Status $lblDisplayName "Nome completo: $($user.DisplayName)" 'Blue'
        } else {
            Set-Status $lblDisplayName "Nome completo: (não definido)" 'Gray'
        }

        # Conta ativa/desativada
        if ($user.Enabled) {
            Set-Status $lblStatusAccount "Active Account" 'Green'
        } else {
            Set-Status $lblStatusAccount "Disabled Account" 'Red'
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

        # Expiração da senha
        $lastPwdSet = $user.LastPasswordSet
        if ($lastPwdSet) {
            $expiry = $lastPwdSet.AddDays(90)
            $daysLeft = ($expiry - (Get-Date)).TotalDays
            if ($daysLeft -gt 0) {
                Set-Status $lblPwdExpiry "Password expired on $([math]::Floor($daysLeft)) days" 'Green'
            } else {
                Set-Status $lblPwdExpiry "Password expired $([math]::Abs([math]::Floor($daysLeft))) days" 'Red'
            }
        } else {
            Set-Status $lblPwdExpiry "Password never expires or not calculable" 'Gray'
        }

        # Expiração da conta
        if ($user.AccountExpirationDate) {
            Set-Status $lblAccountExpiry "Account expired on: $($user.AccountExpirationDate.ToUniversalTime()) (UTC)" 'Red'
        } else {
            Set-Status $lblAccountExpiry "Account: Never expires" 'Green'
        }

        # Lista de grupos
        $groups = $user.GetGroups()
        foreach ($g in $groups) {
            $listGroups.Items.Add($g.Name)
        }

        # Caminho da OU
        if ($user.DistinguishedName) {
            $ouPath = ($user.DistinguishedName -replace '^CN=[^,]+,', '') `
                      -replace 'OU=', '' `
                      -replace 'DC=', '' `
                      -replace ',', '/'
            $ouPath = "$ouPath"
            $txtOU.Text = $ouPath
        } else {
            $txtOU.Text = "OU not found"
        }

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, "Error")
    }
})

$btnValidatePwd.Add_Click({
    Show-ValidatePasswordForm $txtDomain.Text
})

#-----------------------------------------------------------
# EXECUTA FORM PRINCIPAL
#-----------------------------------------------------------
[void]$formMain.ShowDialog()
