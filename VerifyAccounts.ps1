Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

#-----------------------------------------------------------
# FUNÇÃO RANDOM PWD
#-----------------------------------------------------------
function New-RandomPassword {
    param([int]$Length = 14)

    $lower = 'abcdefghijklmnopqrstuvwxyz'
    $upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $numbers = '0123456789'
    $symbols = '!@#$%-&*'

    $all = $lower + $upper + $numbers + $symbols

    # Garantir política
    $password = @()
    $password += $lower[(Get-Random -Maximum $lower.Length)]
    $password += $upper[(Get-Random -Maximum $upper.Length)]
    $password += $numbers[(Get-Random -Maximum $numbers.Length)]
    $password += $symbols[(Get-Random -Maximum $symbols.Length)]

    # Completar o restante
    for ($i = $password.Count; $i -lt $Length; $i++) {
        $password += $all[(Get-Random -Maximum $all.Length)]
    }

    # Embaralhar
    -join ($password | Get-Random -Count $password.Count)
}

#-----------------------------------------------------------
# FORM VALIDAR SENHA
#-----------------------------------------------------------
function Show-ValidatePasswordForm {
    param($DomainDefault)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Validate Password"
    $form.Size = New-Object System.Drawing.Size(440,250)
    $form.StartPosition = "CenterParent"
    $form.Icon = [System.Drawing.SystemIcons]::Application

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
    $txtUser.Add_TextChanged({ $txtUser.BackColor = 'White'})


    $lblPass = New-Object System.Windows.Forms.Label
    $lblPass.Text = "Password:"
    $lblPass.Location = '-32,90'
    $lblPass.TextAlign = 'MiddleRight'
    $form.Controls.Add($lblPass)

    $txtPass = New-Object System.Windows.Forms.TextBox
    $txtPass.Location = '80,88'
    $txtPass.Size = '280,20'
    $txtPass.UseSystemPasswordChar = $true
    $form.Controls.Add($txtPass)
    $txtPass.Add_TextChanged({ $txtPass.BackColor = 'White'})

    
$btnShowPass = New-Object System.Windows.Forms.Button
$btnShowPass.Text = "Show"
$btnShowPass.Location = '365,86'
$btnShowPass.Size = '50,23'
$form.Controls.Add($btnShowPass)

$btnShowPass.Add_Click({

        if ($txtPass.UseSystemPasswordChar) {
            # Mostra senha
            $txtPass.UseSystemPasswordChar = $false
            $btnShowPass.Text = "Hide"
        }
        else {
            # Oculta senha
            $txtPass.UseSystemPasswordChar = $true
            $btnShowPass.Text = "Show"
        }

    })

    $btnValidate = New-Object System.Windows.Forms.Button
    $btnValidate.Text = "Validate"
    $btnValidate.Location = '80,120'
    $form.Controls.Add($btnValidate)

    $lblResult = New-Object System.Windows.Forms.Label
    $lblResult.Location = '20,150'
    $lblResult.Size = '340,40'
    $lblResult.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblResult.TextAlign = 'MiddleCenter'
    $lblResult.BorderStyle = 'FixedSingle'
    $lblResult.BackColor = 'LightGray'
    $form.Controls.Add($lblResult)

$btnValidate.Add_Click({

    try {
        if ([string]::IsNullOrWhiteSpace($txtUser.Text)) {
            $txtUser.BackColor = 'LightPink'
            [System.Windows.Forms.MessageBox]::Show("User is required.", "Validation")
            return
        } else {
            $txtUser.BackColor = 'White'
        }

        if ([string]::IsNullOrWhiteSpace($txtPass.Text)) {
            $txtPass.BackColor = 'LightPink'
            [System.Windows.Forms.MessageBox]::Show("Password is required.", "Validation")
            return
        } else {
            $txtPass.BackColor = 'White'
        }

        $form.Cursor = 'WaitCursor'

        $lblResult.Text = "Validating credentials..."
        $lblResult.BackColor = 'Orange'
        $lblResult.ForeColor = 'Black'

        [System.Windows.Forms.Application]::DoEvents()

        # -------------------------------------------------------
        # PROCESSAMENTO
        # -------------------------------------------------------
        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext `
            ([System.DirectoryServices.AccountManagement.ContextType]::Domain, $txtDomain.Text)

        if ($ctx.ValidateCredentials($txtUser.Text, $txtPass.Text)) {

            $lblResult.Text = "User authenticated successfully"
            $lblResult.BackColor = '#28a745'
            $lblResult.ForeColor = 'White'

        } else {

            $lblResult.Text = "Invalid username or password"
            $lblResult.BackColor = '#dc3545'
            $lblResult.ForeColor = 'White'
        }

    } catch {

        $lblResult.Text = "Error validating credentials"
        $lblResult.BackColor = '#dc3545'
        $lblResult.ForeColor = 'White'

    } finally {

        $form.Cursor = 'Default'
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
    $form.Size = New-Object System.Drawing.Size(450,250)
    $form.StartPosition = "CenterParent"
    $form.Icon = [System.Drawing.SystemIcons]::Application

    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Text = "User:"
    $lblUser.Location = '20,20'
    $form.Controls.Add($lblUser)

    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = '150,18'
    $txtUser.Size = '200,20'
    $form.Controls.Add($txtUser)
    $txtUser.Add_TextChanged({ $txtUser.BackColor = 'White'})######

    $lblOldPass = New-Object System.Windows.Forms.Label
    $lblOldPass.Text = "Old password:"
    $lblOldPass.Location = '20,60'
    $form.Controls.Add($lblOldPass)

    $txtOldPass = New-Object System.Windows.Forms.TextBox
    $txtOldPass.Location = '150,58'
    $txtOldPass.Size = '200,20'
    $txtOldPass.UseSystemPasswordChar = $true
    $form.Controls.Add($txtOldPass)
    $txtOldPass.Add_TextChanged({ $txtOldPass.BackColor = 'White'})#####

    $lblNewPass = New-Object System.Windows.Forms.Label
    $lblNewPass.Text = "New password:"
    $lblNewPass.Location = '20,100'
    $form.Controls.Add($lblNewPass)

    $txtNewPass = New-Object System.Windows.Forms.TextBox
    $txtNewPass.Location = '150,98'
    $txtNewPass.Size = '200,20'
    $txtNewPass.UseSystemPasswordChar = $true
    $form.Controls.Add($txtNewPass)
    $txtNewPass.Add_TextChanged({ $txtNewPass.BackColor = 'White'})#####
    
    $btnCopyPass = New-Object System.Windows.Forms.Button
    $btnCopyPass.Text = "Copy"
    $btnCopyPass.Location = '355,95'
    $btnCopyPass.Size = '50,23'
    $form.Controls.Add($btnCopyPass)

    $btnCopyPass.Add_Click({
    if (-not [string]::IsNullOrWhiteSpace($txtNewPass.Text)) {
        [System.Windows.Forms.Clipboard]::SetText($txtNewPass.Text)
        [System.Windows.Forms.MessageBox]::Show("Password copied to clipboard!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("No password to copy.", "Warning")
    }
})
    
    $btnShowPass = New-Object System.Windows.Forms.Button
    $btnShowPass.Text = "Show"
    $btnShowPass.Location = '355,55'
    $btnShowPass.Size = '50,23'
    $form.Controls.Add($btnShowPass)

    $btnShowPass.Add_Click({
        if ($txtNewPass.UseSystemPasswordChar) {
            $txtNewPass.UseSystemPasswordChar = $false
            $btnShowPass.Text = "Hide"
        } else {
            $txtNewPass.UseSystemPasswordChar = $true
            $btnShowPass.Text = "Show"
        }
    })

    $btnShowPass.Add_Click({
        if ($txtOldPass.UseSystemPasswordChar) {
            $txtOldPass.UseSystemPasswordChar = $false
            $btnShowPass.Text = "Hide"
        } else {
            $txtOldPass.UseSystemPasswordChar = $true
            $btnShowPass.Text = "Show"
        }
    })
    
    $btnGenPass = New-Object System.Windows.Forms.Button
    $btnGenPass.Text = "Generate"
    $btnGenPass.Location = '250,150'
    $btnGenPass.Size = '100,30'
    $form.Controls.Add($btnGenPass)

    $btnGenPass.Add_Click({
    $txtNewPass.Text = New-RandomPassword -Length 14
    })

    $btnConfirm = New-Object System.Windows.Forms.Button
    $btnConfirm.Text = "Modify"
    $btnConfirm.Location = '150,150'
    $btnConfirm.Size = '100,30'
    $form.Controls.Add($btnConfirm)

    $btnConfirm.Add_Click({
        try {
# ------------------------------------         
# VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS
# ------------------------------------
        if ([string]::IsNullOrWhiteSpace($txtUser.Text)) {
            $txtUser.BackColor = 'LightPink'
            [System.Windows.Forms.MessageBox]::Show("User is required.", "Validation")
            $txtUser.Focus()
            return
        } else {
            $txtUser.BackColor = 'White'
        }

        if ([string]::IsNullOrWhiteSpace($txtOldPass.Text)) {
            $txtOldPass.BackColor = 'LightPink'
            [System.Windows.Forms.MessageBox]::Show("Old password is required.", "Validation")
            $txtOldPass.Focus()
            return
        } else {
            $txtOldPass.BackColor = 'White'
        }

        if ([string]::IsNullOrWhiteSpace($txtNewPass.Text)) {
            $txtNewPass.BackColor = 'LightPink'
            [System.Windows.Forms.MessageBox]::Show("New password is required.", "Validation")
            $txtNewPass.Focus()
            return
        } else {
            $txtNewPass.BackColor = 'White'
        }
        
        # Validação de mínimo 12 caracteres
        if ($txtNewPass.Text.Length -lt 12) {
            $txtNewPass.BackColor = 'LightPink'
            [System.Windows.Forms.MessageBox]::Show("Password must be at least 12 characters.", "Validation")
            $txtNewPass.Focus()
            return
        }


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
$formMain.Text = "Accounts Verify AD Tools"
$formMain.Size = New-Object System.Drawing.Size(830,380)
$formMain.StartPosition = "CenterScreen"
# $formMain.Font = New-Object System.Drawing.Font("Segoe UI",9)
$formMain.Icon = [System.Drawing.SystemIcons]::Application


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
$txtDomain.Add_TextChanged({ $txtDomain.BackColor = 'White'})

$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = "UPN or E-mail:"
$lblUser.Location = '10,55'
$lblUser.Size = '80,20'
$formMain.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = '100,53'
$txtUser.Size = '430,20'
$formMain.Controls.Add($txtUser)
$txtUser.Add_TextChanged({ $txtUser.BackColor = 'White'})

$txtUser.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        $btnVerify.PerformClick()
    }
})

$btnVerify = New-Object System.Windows.Forms.Button
$btnVerify.Text = "Verify User"
$btnVerify.Location = '100,85'
$btnVerify.Size = '100, 30'
$formMain.Controls.Add($btnVerify)

$btnValidatePwd = New-Object System.Windows.Forms.Button
$btnValidatePwd.Text = "Validate Password"
$btnValidatePwd.Location = '210,85'
$btnValidatePwd.Size = '100,30'
$formMain.Controls.Add($btnValidatePwd)

$btnChangePass = New-Object System.Windows.Forms.Button
$btnChangePass.Text = "Reset Password"
$btnChangePass.Location = '320,85'
$btnChangePass.Size = '100,30'
$formMain.Controls.Add($btnChangePass)

$lblFooterMain = New-Object System.Windows.Forms.Label
$lblFooterMain.Text = "EDAM IT Local AD Tools - v2.1"
$lblFooterMain.AutoSize = $true
$lblFooterMain.ForeColor = 'Black'
$lblFooterMain.Location = '620,305'
$formMain.Controls.Add($lblFooterMain)

$lblFooterSub = New-Object System.Windows.Forms.Label
$lblFooterSub.Text = "Manaus-AM, $(Get-Date -Format yyyy)"
$lblFooterSub.AutoSize = $true
$lblFooterSub.ForeColor = 'Blue'
$lblFooterSub.Location = '620,320'
$formMain.Controls.Add($lblFooterSub)

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
# ToolTip Bottons
#-----------------------------------------------------------
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.SetToolTip($btnVerify, "Check user or email.")
$tooltip.SetToolTip($btnValidatePwd, "Verifies if the user's password is valid.")
$tooltip.SetToolTip($btnChangePass, "Button to reset EXPIRED passwords, or if the old password is known.")
$tooltip.SetToolTip($btnClear, "Clears all fields except the Domain.")

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

#-----------------------------------------------------------
# Label "Member Of:"
#-----------------------------------------------------------
$lblGroupsTitle = New-Object System.Windows.Forms.Label
$lblGroupsTitle.Text = "Member Of:"
$lblGroupsTitle.Location = '550,0'  # Posição acima da ListBox
$lblGroupsTitle.Size = '200,18'
$formMain.Controls.Add($lblGroupsTitle)
# -------------------

$listGroups = New-Object System.Windows.Forms.ListBox
$listGroups.Location = '550,18'
$listGroups.Size = '240,280'
$formMain.Controls.Add($listGroups)


#-----------------------------------------------------------
# EVENTOS
#-----------------------------------------------------------

$btnVerify.Add_Click({

    # Ativa cursor de carregando
    $formMain.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    [System.Windows.Forms.Application]::DoEvents()

    try {

    $lblDisplayName.Text = ""
    $lblStatusAccount.Text = ""
    $lblStatusLock.Text = ""
    $lblEmail.Text = ""
    $lblPwdExpiry.Text = ""
    $lblAccountExpiry.Text = ""
    $listGroups.Items.Clear()

    #-----------------------------------------------------------
    # VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS
    #-----------------------------------------------------------
    if ([string]::IsNullOrWhiteSpace($txtDomain.Text)) {
        $txtDomain.BackColor = 'LightPink'
        [System.Windows.Forms.MessageBox]::Show("Domain is required.", "Validation")
        $txtDomain.Focus()
        return
    } else {
        $txtDomain.BackColor = 'White'
    }

    if ([string]::IsNullOrWhiteSpace($txtUser.Text)) {
        $txtUser.BackColor = 'LightPink'
        [System.Windows.Forms.MessageBox]::Show("User or Email is required.", "Validation")
        $txtUser.Focus()
        return
    } else {
        $txtUser.BackColor = 'White'
    }

    try {
        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext `
            ([System.DirectoryServices.AccountManagement.ContextType]::Domain, $txtDomain.Text)

        # Primeiro tenta buscar pelo sAMAccountName (login)
        $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($ctx, $txtUser.Text)

        # Se não achar UPN, tenta buscar pelo e-mail
        if (-not $user) {
            $searcher = New-Object DirectoryServices.DirectorySearcher
            $searcher.SearchRoot = "LDAP://$($txtDomain.Text)"
            $searcher.Filter = "(&(objectClass=user)(|(mail=$($txtUser.Text))(userPrincipalName=$($txtUser.Text))))"
            $searcher.PropertiesToLoad.Add("samaccountname") | Out-Null
            $result = $searcher.FindOne()
            if ($result) {
                $sam = $result.Properties["samaccountname"][0]
                $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($ctx, $sam)
            }
        }

        if (-not $user) {
            [System.Windows.Forms.MessageBox]::Show("User not found (check username or email).", "Notice", 0, "Warning")
            return
        }
# finalizou alteração aqui


        # Display Name
        if ($user.DisplayName) {
            Set-Status $lblDisplayName "Full Name: $($user.DisplayName)" 'Blue'
        } else {
            Set-Status $lblDisplayName "Full Name: (Not Defined)" 'Gray'
        }

        # Conta ativa/desativada
        if ($user.Enabled) {
            Set-Status $lblStatusAccount "Active Account" 'Green'
        } else {
            Set-Status $lblStatusAccount "Disabled Account" 'Red'
        }

        # Conta bloqueada
        if ($user.IsAccountLockedOut()) {
            Set-Status $lblStatusLock "Locked Account" 'Red'
        } else {
            Set-Status $lblStatusLock "Unlocked Account" 'Green'
        }

        # Email
        if ($user.EmailAddress) {
            Set-Status $lblEmail "E-mail: $($user.EmailAddress)" 'Green'
        } else {
            Set-Status $lblEmail "E-mail: (Not Defined)" 'Gray'
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
    
    } finally {
        # Volta o cursor Defaultt
        $formMain.Cursor = [System.Windows.Forms.Cursors]::Default
    }


})


$btnValidatePwd.Add_Click({
    Show-ValidatePasswordForm $txtDomain.Text
})

#-----------------------------------------------------------
# EXECUTA FORM PRINCIPAL
#-----------------------------------------------------------
[void]$formMain.ShowDialog()
