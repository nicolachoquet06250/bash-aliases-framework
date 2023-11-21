$ALIASES_FRAMEWORK_DEFINED = 1

# eval = Invoke-Expression "expression-str"

function framework_create_help {
    $help_lines = @(
        "${args[1]} help"
        "${args[1]} --help"
        "${args[1]} -h"
        "${args[1]}"
    )
    shift
    $commands_lines = $args

    $width = $(tput cols) - 1

    $middle_char = "="
    $left_and_right_char = "|"
    $char_left_and_right_char = " "

    $first_and_last_line = $left_and_right_char
    for ($cmp=0; $cmp<($width - 2); $cmp++) {
        $first_and_last_line += $middle_char
    }
    $first_and_last_line += $left_and_right_char

    $middle_line = ""
    for ($j=0; $j<($width - 1); $j++) {
        If ($j -eq 0) {
            $middle_line += " "
        } else {
            $middle_line += "_"
        }
    }

    function title_block {
        $title = $args[1]

        $middle_char = "="

        $extrem_start="${left_and_right_char}${middle_char}${middle_char}${char_left_and_right_char}"
        $extrem_stop="${char_left_and_right_char}${middle_char}${middle_char}${left_and_right_char}"

        $real_width=($width - ($extrem_start.Length * 2))
        $left_and_right_line_char_width=(($width / 2) - $extrem_start.Length - (($title.Length / 2) + 1))

        $middle_char="-"

        Write-Output $first_and_last_line
        Write-Host -NoNewLine "${extrem_start}"

        $half_of_title_length = $title.Length / 2

        $max = $left_and_right_line_char_width
        If (($half_of_title_length.GetType().Name -eq "Double") -and ((($width - $title.Length) % 2) -eq 1)) {
            $max = $left_and_right_line_char_width - 1
        }

        for ($cmp=0; $cmp<$max; $cmp++) {
            Write-Host -NoNewLine $middle_char
        }

        Write-Host -NoNewLine " ${title} "

        $max = $left_and_right_line_char_width
        If (-not ($half_of_title_length.GetType().Name -eq "Double") -and ((($width - $title.Length) % 2) -eq 1)) {
            $max = $left_and_right_line_char_width + 1
        }

        for ($cmp=0; $cmp<$max; $cmp++) {
            Write-Host -NoNewLine $middle_char
        }

        Write-Output $extrem_stop
        Write-Output $first_and_last_line
    }

    $extrem_start = "|== "
    $extrem_stop = " ==|"
    $real_width = $width - ($extrem_start.Length * 2)

    Write-Output $middle_line
    title_block "Commandes"

    for ($i=0; $i<$commands_lines.Count; $i++) {
        $line = $commands_lines[$i]
        $line_width = $line.Length

        $start_with_emoji = 0
        If (($line.Contains("⬆️")) -or ($line.Contains("➡️"))) {
            $start_with_emoji = 1
            $line_width += 1
        }

        If ($line_width -gt $real_width) {
            $line = $commands_lines[$i]

            If ($start_with_emoji -eq 1) {
                $line += " "
            }
            $split_line = @()
            $index = 0
            $last_limit = $real_width

            for ($l=0; $l<$line.Length; $l++) {
                $char = $line.Substring($l, 1)
                $split_line[$index] += $char

                If ($l -ge ($last_limit - 2)) {
                    $index += 1
                    $last_limit += $real_width
                }
            }

            for ($line_index=0; $line_index<$split_line.Count; $line_index++) {
                $str = ""
                for ($j=0; $j<$split_line[$line_index].Length; $j++) {
                    $str += " "
                }

                If (($split_line[$line_index].Contains("⬆️")) -or ($split_line[$line_index].Contains("➡️"))) {
                    $str += " "
                }

                Write-Output "${extrem_start}${split_line[$line_index]} ${str}${extrem_stop}"
            }
        } else {
            $str = ""
            for ($j=0; $j<((($line_width - $real_width) * -1) - 1); $j++) {
                $str += " "
            }

            If ($start_with_emoji -eq 1) {
                $str += "  "
            }

            Write-Output "${extrem_start}${commands_lines[$i]} ${str}${extrem_stop}"
        }
    }

    title_block "Help"

    for ($i=0; $i<$help_lines.Count; $i++) {
        $str = ""
        for ($j=0; $j<((($help_lines[$i].Length - $real_width) * -1) - 1); $j++) {
            $str += " "
        }

        Write-Output "${extrem_start}${help_lines[$i]} ${str}${extrem_stop}"
    }

    Write-Output $first_and_last_line

    for ($j=0; $j<($first_and_last_line.Length - 1); $j++) {
        If ($j -eq 0) {
            Write-Host -NoNewLine " "
        } else {
            Write-Host -NoNewLine "-"
        }
    }
    Write-Output ""
}

function framework_flag {
    return '
        $params = $args

        function flag {
            $p = $params
            $name = $args[1]
            $short_name = $args[2]
            If ($short_name -eq "") {
                $short_name = $name.Substring(0, 1)
            }

            #      le flag exist
            If ($p.Contains("--$name") -or $p.Contains("-$short_name")) {
                $cmp = 0
                $selected_value = "false"
                for ($f=0; $f<$params.Count; $f++) {
                    $flag = $params[$f]

                    If ((($flag.Substring(0, 2) -eq "--") -and ($flag.Substring(2, $flag.Length) -eq $name)) -of (($flag.Substring(0, 1) -eq "-") -and ($flag.Substring(1, $flag.Length) -eq $short_name))) {
                        If (($params[$cmp + 1] -eq "") -or ($params[$cmp + 1].Substring(0, 2) -eq "--") -or ($params[$cmp + 1].Substring(0, 1) -eq "-")) {
                            $selected_value = $true
                        } else {
                            $selected_value = $params[$cmp + 1]
                        }
                    }
                }

                return $selected_value
            } else {
                return $false
            }
          }
    '
}

function framework_command_checker {
    Invoke-Expression $(framework_flag)

    $code = '$chosen_command=$args[1]'

    If (-not (flag "with-help" "wh" -eq $false)) {
        $code += '
        If (($chosen_command -eq "--help") -or ($chosen_command -eq "-h") -or ($chosen_command -eq "")) {
            $chosen_command = "help"
        }
        '
    }

    $code += '
    $command_exists = 0
    for ($c=0; $c<$commands.Count; $c++) {
      If ($command -eq $chosen_command) {
        $command_exists = 1
        break
      }
    }
    '

    return $code
}

function framework_run_command {
    Invoke-Expression $(framework_flag)

    $error = flag "error" "err"

    $code = '
    $command=$chosen_command.replace(":", "_")
    If ($command_exists -eq 1) {
      If ($start -eq $null) {
        $start = 2
      }
      $size=$args.Count

      Invoke-Expression $command $args[$start..$size]
    } else {
    '
    If ($error -eq $false) {
        $code += 'framework_error_message "command \"${FUNCNAME[0]} ${chosen_command}\" not found"'
    } else {
        $code += "framework_error_message '${error}'"
    }
    $code += '}

    Write-Output ""
    '

    return $code
}

function function_generate_shorts_commands {
    return '
    foreach ($alias in $shorts.Keys) {
      Invoke-Expression "function ${alias} {
        Invoke-Expression ${shorts.$alias} \$args
      }"
    }
    '
}

function framework_success_message {
    return "✅ ${args[1]}"
}

function framework_is_success_message {
    If ($args[1].Substring(0, 1) -eq "✅") {
        return $true
    } else {
        return $false
    }
}

function framework_warning_message {
    return "⚠️  ${args[1]}"
}

function framework_is_warning_message {
    If ($args[1].Substring(0, 1) -eq "⚠️") {
        return $true
    } else {
        return $false
    }
}

function framework_error_message {
    return "❌ ${args[1]}"
}

function framework_is_error_message {
    If ($args[1].Substring(0, 1) -eq "❌") {
        return $true
    } else {
        return $false
    }
}

function framework_generate_doc {
    $list = $args[1]

    $code = ""
    for ($i=0; $i<$list.Count; $i++) {
        $code += "Write-Output \"⬜ ${$list[$i]}\""
    }

    return $code
}

function framework_link {
    $link=$1
    If ($link.Substring(0, 1) -eq "/") {
        $link="file://${link}"
    }

    $label=$2
    If ($label -eq "") {
        $label=$link
    }

    If ($label -eq $link) {
        return $link
    } else {
        return "$label($link)"
    }
}

function framework_format {
    Invoke-Expression $(framework_flag)

    $formats = @{
        weight = @{
            open = '**'
            close = '**'
        }
        underline = @{
            open = '<u>'
            close = '</u>'
        }
        italic = @{
            open = '*'
            close = '*'
        }
    }

    $colors = @(
        "Black"
        "DarkBlue"
        "DarkGreen"
        "DarkCyan"
        "DarkRed"
        "DarkMagenta"
        "DarkYellow"
        "Gray"
        "DarkGray"
        "Blue"
        "Green"
        "Cyan"
        "Red"
        "Magenta"
        "Yellow"
        "White"
    )

    $str = ""

    $text = flag "text" "t"
    If ($text -ne $false) {
        $str += $text
    }

    foreach ($format in $formats.Keys) {
        If ($(flag "${format}") -eq $true) {
            $text = "${formats[$format].open}"$text"${formats[$format].close}"
        }
    }
    $str = $text

    $color_flag = flag "color" "c"
    $usingColor = $false
    foreach ($color in $colors) {
        If ($color_flag -eq $color) {
            $usingColor = $color
            break
        }
    }

    If ($color_flag == $false) {
        Write-Output ($str | ConvertFrom-MarkDown -AsVt100EncodedString).VT100EncodedString
    } else {
        Write-Host -ForegroundColor $usingColor ($str | ConvertFrom-MarkDown -AsVt100EncodedString).VT100EncodedString
    }
}

function framework_title {
    Invoke-Expression $(framework_flag)

    _ = $(Install-Module -Name Figlet -Force)

    mkdir -p "${HOME}/aliases/fonts"

    $line_prefix = flag "line_prefix" "lpre"
    $text = flag "text" "t"
    $font = flag "font" "f"

    If ($font -ne $false) {
        If (($font.Substring(0, 8) -eq "https://") -or ($font.Substring(0, 7) -eq "http://")) {
            $font_parts = $font.Split("/")
            $font_name = $font_parts[-1].Split(".")[0].replace("%20", "_")

            If (-not (Test-Path "${HOME}/aliases/fonts/${font_name}.flf")) {
                curl -s "${font}" > "${HOME}/aliases/fonts/${font_name}.flf"
            }

            $font = $font_name
        } elseif (-not (Test-Path "${HOME}/aliases/fonts/${font}.flf")) {
            curl -s "http://www.figlet.org/fonts/${font}.flf" > "${HOME}/aliases/fonts/${font}.flf"
        }

        $command = "figlet -w $(tput cols)"

        If ("$(flag "center" "c")" -ne $false) {
            $command += " -c"
        }

        If ($font -ne $false) {
            $command += " -f ${HOME}/aliases/fonts/${font}.flf"
        }

        $command += " '${text}'"

        If ("$(flag "space-top" "st")" -eq $true) {
            Write-Output ""
        }

        If ($line_prefix -eq $false) {
            Invoke-Expression $command
        } else {
            out = $("${command}")
            $lines = $out.Split("\n")

            foreach ($line in $lines) {
                Write-Output "${line_prefix}${line}"
            }
        }

        If ("$(flag "space-bottom" "sb")" -eq $true) {
            Write-Output ""
        }
    }
}

function framework_figlet_font_path {
    echo "https://unpkg.com/figlet@1.4.0/fonts/${args[1].Substring(0, 1).ToUpper()}${args[1].Substring(1)}.flf"
}

function framework_max_str_width {
    $str = $args[1]
    $lines = $str.Split("\n")
    $max_width = 0

    foreach ($line in $lines) {
        If ($line.Length -gt $max_width) {
            $max_width = $line.Length
        }
    }

    return $max_width
}

function framework_sub_command {
    Invoke-Expression $(framework_flag)

    $command = flag "name" "n"

    If ($command -eq $false) {
        return $(framework_error_message "Vous devez spécifier le nom !")
    }

    $command_short = "$(flag "short" "s")"

    $code = '
    if [[ $commands -eq $null ]];then
        $commands = @()
    fi

    $commands+=('$command')
    '

    If ($command_short -ne $false) {
        $code += '
        $commands+=('$command_short')

        If ($shorts -eq $null) {
            $shorts = @{}
        }

        $shorts["'$command_short.replace(':', '_')'"]="'$command.replace(':', '_')'"
        '
    }

    $func = flag "func" "f"

    If ($func -ne $false) {
        $code += '
        function '$command.replace(':', '_')'() {
            '$func'
        }
        '
    }

    return $code
}

function framework_run {
    Invoke-Expression $(framework_flag)

    $code = '
    Invoke-Expression $framework_generate_shorts_commands
    '

    If ("$(flag "with-help" "wh")" -eq $true) {
        $code += '
        Invoke-Expression $(framework_command_checker --with-help)
        '
    } else {
        $code += '
        Invoke-Expression $(framework_command_checker)
        '
    }

    If ("$(flag "error" "err")" -ne $false) {
        $code += '
        Invoke-Expression $(framework_run_command --error "'$(flag "error" "err")'")
        '
    } else {
    #  Message d'erreur par default : \"command \\\"alwaysdata \${chosen_command}\\\" not found\"
        $code += '
        Invoke-Expression $(framework_run_command)
        '
    }
}

function __ {
    $lang=$(echo "$(locale | grep LANG=)" | sed 's/LANG=//; s/.UTF-8//')

    If (($trad -ne $null) -and ($trad[$lang] -ne $null) -and ($trad[$lang][$args[1]] -ne $null) -and ($trad[$lang][$args[1]] -ne "")) {
        return $trad[$lang][$args[1]]
    } else {
        return $args[1]
    }
}

function timestamp {
    return $(date +%s)
}

function framework {
    Invoke-Expression $(framework_flag)

    function logo {
        title="Framework"
        title_font_family="block"

        return $(framework_title --text "${title}" --font "${title_font_family}" --line_prefix "  " -st)
    }

    logo

    function help {
        return $(framework_create_help "framework" @(
            'framework_flag'
            '➡️  Génère une fonction `flag` avec la signature suivante : flag "nom long" "nom court optionel"'
            ''
            'framework_command_checker [--with-help]'
            '➡️  Génère le code bash permétant de vérifier que le sous alias saisis est valide est à été déclaré'
            ''
            'framework_generate_shorts_commands'
            "➡️  Génère les fonctions de l'alias short en fonction de la fonction de l'alias long."
            ''
            'framework_success_message "message"'
            '➡️  Affiche un message avec un tick vert devant'
            ''
            'framework_is_success_message "message"'
            '➡️  Vérifie que le message à pour premier charactère un tick vert'
            ''
            'framework_warning_message "message"'
            '➡️  Affiche un message avec un panneau attention orange devant'
            ''
            'framework_is_warning_message "message"'
            '➡️  Vérifie que le message à pour premier charactère un panneau attention orange'
            ''
            'framework_error_message "message"'
            '➡️  Affiche un message avec une croix rouge devant'
            ''
            'framework_is_error_message "message"'
            '➡️  Vérifie que le message à pour premier charactère une croix rouge'
            ''
            'framework_generate_doc reference_de_tableau'
            "➡️  Mise en forme d'une liste destiné à de la documentation"
            ''
            'framework_link "url|local_path" "label"'
            "➡️  Formatte le texte pour qu'il soit clickable via ctrl+click avec une url ou un chemin local donné."
            ''
            'framework_format --text|-t content [--underline] [--weight] [--color|-c \"default|black|white|red|lightred|green|lightgreen|yellow|lightyellow|blue|lightblue|purple|lightpurple|cyan|lightcyan|gray|lightgray|darkgray\"]'
            ''
            'framework_figlet_font_path "font_name"'
            "➡️  Génère l'url de téléchargement d'une font figlet via sont nom"
            ''
            'framework_max_str_width "multilines_str"'
            "➡️  Donne la largeur maximal d'une chaine multi-lignes"
            ''
            'framework_sub_command --name|-n sub_command_name --short|-s short_sub_command_name'
            "➡️  Cette fonction est appelé après la définition d'une fonction que l'on utilisera en sous alias"
            "➡️  Les caractères ':' dans l'alias seront remplacés par '_' dans le nom de la fonction et dans le nom du short."
            ''
            'framework_run [--with-help] [--error|-err "error message"]'
            '➡️  Lance les fonctions suivantes de manière regroupées dans cet ordre :'
            '  1. framework_generate_shorts_commands'
            '  2. framework_command_checker [--with-help]'
            '  3. framework_run_command [--error default="command \"alwaysdata ${chosen_command}\" not found"]'
            ''
            '__ "message"'
            '➡️  Récupère la valeur associée à la cle de traduction "message"'
            'et à la langue du systeme définie dans un tableau "trad" dans une fonction appelante.'
            ''
            'timestamp'
            '➡️  Donne la date courrente sous forme de timestamp'
            ''
            'framework tools:sites:list'
            '⬆️  framework tools:s:l'
        ))
    }
    Invoke-Expression $(framework_sub_command -n "help")

    function tools_sites_list {
        $list=@(
            "- Figlet"
            "Liste des fonts=https://devhints.io/figlet"
        )

        framework_warning_message $(framework_format --weight -t "La liste ci-dessous est clickable (ctrl-click)")
        Write-Output ""

        $window_length = $(tput cols)
        $cmp = 0
        foreach ($line in $list) {
            If ($line.Substring(0, 2) -eq "- ") {
                If ($cmp -gt 0) {
                    Write-Output ""
                }
                $width = 80

                If (80 -gt $window_length) {
                    $width = $window_length
                }

                $left = "|= "
                $right = " =|"

                $title = $(framework_format --underline -t $line.Substring(2))

                $left_limit = (($width / 2) - ($title.Length / 2)) - 1

                $half_title_length = $title.Length / 2

                If ($half_title_length.GetType().Name -eq "Double") {
                    $left_limit += 1
                }

                $left_part = $left
                for ($i=0; $i<$left_limit; $i++) {
                    $left_part += "="
                }

                $right_part = ""
                for ($i=0; $i<((($width / 2) - ($title.Length / 2)) - 1); $i++) {
                    $right_part += "="
                }
                $right_part += $right

                Write-Output "${left_part} $(framework_format --underline -t $line.Substring(2)) ${right_part}"
                Write-Output ""
                continue
            }

            If ($line.Contains("=")) {
                $parts = $line.Split("=")
                Write-Host -NoNewLine " • $(framework_link "${parts[1]}" "$(framework_format --underline -t "${parts[0]}")")"
                Write-Output ""
            } else {
                Write-Host -NoNewLine " • $(framework_link "${line}")"
            }

            $cmp++
        }
    }
    Invoke-Expression $(framework_sub_command -n "tools:sites:list" -s "tools:s:l")

    Invoke-Expression $(framework_run --with-help)
}
