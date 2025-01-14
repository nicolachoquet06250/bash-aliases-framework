If (-not (Test-Path "${HOME}/.bash-aliases-framework")) {
    If ($args[0] -eq "install-script") {
        $path = "/bash-aliases-framework"

        Write-Output "${HOME}/.bash-aliases-framework"
        Write-Output "$( Get-Location )${path}"

        New-Item -ItemType SymbolicLink -Path "${HOME}/.bash-aliases-framework" -Target "$( Get-Location )${path}"
    }
}
