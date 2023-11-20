If (-not (Test-Path "${HOME}/.bash-aliases-framework")) {
    $path = ""
    If ($args[1] -eq "install-script") {
        $path = "/bash-aliases-framework"
    }
    New-Item -ItemType SymbolicLink -Path "$(Get-Location)$path" -Target "$HOME/.bash-aliases-framework"
}

$file_path = ".bash-aliases-framework/.aliases.ps1"
$source = "source \"\${HOME}/$file_path\""

If (-not (Select-String $profile -Pattern $source)) {
    Set-Content -Path $profile -Value $source
}