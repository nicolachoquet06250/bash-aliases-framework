#!/bin/bash

# penser à mettre à jour l'alias sur git en supprimant ce commentaire
export ALIASES_FRAMEWORK_DEFINED=1

function framework_create_help() {
  help_lines=( "$1 help" "$1 --help" "$1 -h" "$1" )
  shift
  commands_lines=("$@")

  width=$(($(tput cols)-1))

  #   Header drawing
  middle_char="="
  left_and_right_char="|"
  char_left_and_right_char=" "

  first_and_last_line="${left_and_right_char}"
  for (( cmp=0; cmp<$((width - 2)); cmp++ ));do
    first_and_last_line+="${middle_char}"
  done
  first_and_last_line+="${left_and_right_char}"

  middle_line=""
  for ((j=0; j<$(( width - 1 )); j++));do
    [ "$j" -eq 0 ] && middle_line+=" " || middle_line+="_"
  done

  function title_block() {
      title=$1

      middle_char="="

      extrem_start="${left_and_right_char}${middle_char}${middle_char}${char_left_and_right_char}"
      extrem_stop="${char_left_and_right_char}${middle_char}${middle_char}${left_and_right_char}"
      real_width=$(( width - (${#extrem_start} * 2) ))

      left_and_right_line_char_width=$(( ( width / 2 ) - ${#extrem_start} - ( ( ${#title} / 2 ) + 1 ) ))

      middle_char="-"

      echo $first_and_last_line
      echo -n "${extrem_start}"

      if [[ "$(echo "scale=2; ${#title}/2" | bc)" =~ .5 ]] && [[ "$(( (width - ${#title}) % 2 ))" == "1" ]];then
        for (( cmp=0; cmp<$((left_and_right_line_char_width-1)); cmp++ ));do
          echo -n "${middle_char}"
        done
      else
        for (( cmp=0; cmp<left_and_right_line_char_width; cmp++ ));do
          echo -n "${middle_char}"
        done
      fi

      echo -n " ${title} "

      if [[ "$(echo "scale=2; ${#title}/2" | bc)" =~ .00 ]] && [[ "$(( (width - ${#title}) % 2 ))" == "1" ]];then
        for (( cmp=0; cmp<$((left_and_right_line_char_width+1)); cmp++ ));do
          echo -n "${middle_char}"
        done
      else
        for (( cmp=0; cmp<left_and_right_line_char_width; cmp++ ));do
          echo -n "${middle_char}"
        done
      fi

      echo "${extrem_stop}"

      echo $first_and_last_line
  }

  extrem_start="|== "
  extrem_stop=" ==|"
  real_width=$(( width - (${#extrem_start} * 2) ))

  echo "${middle_line}"
  title_block "Commandes"
  #   End Header drawing

  #   Body drawing
  for ((i=0; i<$(( ${#commands_lines[*]} )); i++));do
    line="${commands_lines[$i]}"
    line_width=${#line}

    start_with_emoji=0
    if [[ "${line:0:3}" =~ "⬆️" ]] || [[ "${line:0:2}" == "➡️" ]];then
      start_with_emoji=1
      line_width=$((line_width+1))
    fi

    if [ $line_width -gt $real_width ];then
        line="${commands_lines[$i]}"
        [[ "${start_with_emoji}" == "1" ]] && line+=" "
        split_line=()
        index=0
        last_limit=$real_width

        for (( l=0; l<${#line}; l++ ));do
            char="${line:$l:1}"
            split_line[$index]="${split_line[$index]}$char"

            if [ "$l" -ge $(( last_limit - 2 )) ];then
                index=$(( index + 1 ))
                last_limit=$(( last_limit + real_width ))
            fi
        done

        for (( line_index=0; line_index<${#split_line[*]}; line_index++ ));do
            str=""
            for ((j=0; j<$(( ((${#split_line[$line_index]} - real_width) * -1) - 1 )); j++));do
              str+=" ";
            done
            [[ "${split_line[$line_index]:0:3}" =~ "⬆️" ]] || [[ "${split_line[$line_index]:0:3}" =~ "➡️" ]] && str+=" "

            echo "${extrem_start}${split_line[$line_index]} ${str}${extrem_stop}"
        done
    else
        str=""
        for ((j=0; j<$(( ( ( line_width - real_width ) * -1 ) - 1 )); j++));do
          str+=" ";
        done
        [[ "${start_with_emoji}" == "1" ]] && str+="  "

        echo "${extrem_start}${commands_lines[$i]} ${str}${extrem_stop}"
    fi
  done
  #   End Body drawing

  #   Help drawing
  title_block "Help"
  for ((i=0; i<$(( ${#help_lines[*]} )); i++));do
      str=""
      for ((j=0; j<$(( ((${#help_lines[$i]} - real_width) * -1) - 1 )); j++)); do str="$str "; done

      echo "${extrem_start}${help_lines[$i]} ${str}${extrem_stop}"
  done

  echo $first_and_last_line
  for ((j=0; j<$(( ${#first_and_last_line} - 1 )); j++));do
      [ "$j" -eq 0 ] && echo -n " " || echo -n "-"
  done
  echo ""
}

### exec `eval "$(framework_flag)"` in your alias function
function framework_flag() {
  echo "
  # shellcheck disable=SC2034
  declare -a params=(\"\${@}\")

  function flag() {
    declare -a p=(\"\${params[@]}\")
    name=\"\$1\"
    short_name=\"\$2\"
    [[ \"\${short_name}\" == \"\" ]] && short_name=\"\${name:0:1}\"

    #      le flag exist
    if {
      [[ \"\${p[*]}\" =~ --\$name ]] || \
      [[ \"\${p[*]}\" =~ -\$short_name ]]
    };then
      cmp=0
      selected_value=\"false\"
      for flag in \"\${params[@]}\";do
        if {
          [[ \"\${flag:0:2}\" == \"--\" ]] && \
          [[ \"\${flag:2:\${#flag}}\" == \"\${name}\" ]]
        } || {
          [[ \"\${flag:0:1}\" == \"-\" ]] && \
          [[ \"\${flag:1:\${#flag}}\" == \"\${short_name}\" ]]
        };then
          if {
            [[ \"\${params[\$((cmp+1))]}\" == \"\" ]] || \
            [[ \"\${params[\$((cmp+1))]:0:2}\" == \"--\" ]] || \
            [[ \"\${params[\$((cmp+1))]:0:1}\" == \"-\" ]]
          };then
            selected_value=\"true\"
          else
            selected_value=\"\${params[\$((cmp+1))]}\"
          fi
        fi

        cmp=\$((cmp+1))
      done

      echo \"\${selected_value}\"
    else
      echo \"false\"
    fi
  }
  "
}

### you must create `commands` array in your alias function
### and use this function like that after array declaration :
### exec `eval "$(framework_command_checker)"`
function framework_command_checker() {
    eval "$(framework_flag)"
    echo "
    chosen_command=\"\$1\""
    if [[ "$(flag "with-help" "wh")" != false ]];then
      echo "
      {
        [ \"\$chosen_command\" == \"--help\" ] ||
        [ \"\$chosen_command\" == \"-h\" ] ||
        [ \"\$chosen_command\" == \"\" ]
      } && chosen_command=\"help\""
    fi
    echo "
    command_exists=0
    for command in \"\${commands[@]}\";do
      if [[ \"\${command}\" == \"\${chosen_command}\" ]];then
        command_exists=1
        break
      fi
    done
    "
    except_logo_flag="$(flag "except-logo" "el")"
    if [[ "${except_logo_flag}" != false ]] && [[ "${except_logo_flag}" != true ]];then
      echo "
      if {
        [[ ! \"\$(type -t logo)\" =~ \"non trouvé\" ]] &&
        [[ ! \"\$(type -t logo)\" =~ \"not found\" ]]
      };then
        except_logo=\"${except_logo_flag}\"
        IFS=\$','
        read -rd '' -a excepts <<<\"\$except_logo\"

        passed=true
        for except in \"\${excepts[@]}\";do
          except=\"\${except//:/_}\"
          except=\"\${except:0:\$((\${#except} - 1))}\"
          except_short=\"\"

          for short in \"\${!shorts[@]}\";do
            if [[ \"\${shorts[\$short]}\" == \"\${except}\" ]];then
              except_short=\"\${short}\"
            fi
          done

          if {
            {
              [[ \"\${except_short}\" == \"\" ]] &&
              [[ \"\${chosen_command//:/_}\" == \"\${except}\" ]]
            } || {
              [[ \"\${chosen_command//:/_}\" == \"\${except}\" ]] ||
              [[ \"\${chosen_command//:/_}\" == \"\${except_short}\" ]]
            }
          };then
            passed=false
          fi
        done

        [[ \$passed == true ]] && logo
      fi
      "
    fi
}

function framework_run_command() {
  eval "$(framework_flag)"

  error="$(flag "error" "err")"
  echo "
  command=\${chosen_command//':'/'_'}
  if [[ \"\${command_exists}\" == \"1\" ]] && [[ \$(type -t \$command) == function ]];then
    [[ \"\${start}\" == \"\" ]] && start=2
    size=+\"\${#*}\"
    args=(\"\${@:\$start:\$size}\")

    \$command \"\${args[@]}\"
  else"
  if [[ "${error}" == false ]];then
    echo "  framework_error_message \"command \\\"\${FUNCNAME[0]} \${chosen_command}\\\" not found\""
  else
    echo "  framework_error_message \"${error}\""
  fi
  echo "
  fi

  [[ \"\${passed}\" == true ]] && echo \"\"
  "
}

function framework_generate_shorts_commands() {
    echo "
    for alias in \"\${!shorts[@]}\";do
      eval \"function \${alias}() {
        \${shorts[\$alias]} \\\"\\\${@}\\\"
      }\"
    done
    "
}

function framework_success_message() {
    echo "✅ $1"
}

function framework_is_success_message() {
  [[ "${1:0:1}" == "✅" ]] && echo "true" || echo "false"
}

function framework_warning_message() {
    echo "⚠️  $1"
}

function framework_is_warning_message() {
  [[ "${1:0:1}" == "⚠️" ]] && echo "true" || echo "false"
}

function framework_error_message() {
    echo "❌ $1"
}

function framework_is_error_message() {
  [[ "${1:0:1}" == "❌" ]] && echo "true" || echo "false"
}

function framework_generate_doc() {
    local -n list=$1

    for item in "${list[@]}";do
      echo "echo \"⬜ ${item}\""
    done
}

function framework_link() {
  link=$1
  [[ "${link:0:1}" == "/" ]] && link="file://${link}"

  label=$2
  [[ "${label}" == "" ]] && label="${link}"

  echo -e "\e]8;;${link}\a${label}\e]8;;\a"
}

function framework_format() {
    eval "$(framework_flag)"

    declare -A formats=(
      ['weight']="\e[1m"
      ['underline']="\e[4m"
    )

    declare -A colors=(
      ['default']="\e[39m"
      ['black']="\e[30m"
      ['red']="\e[31m"
      ['lightred']="\e[91m"
      ['green']="\e[32m"
      ['lightgreen']="\e[92m"
      ['yellow']="\e[33m"
      ['lightyellow']="\e[93m"
      ['blue']="\e[34m"
      ['lightblue']="\e[94m"
      ['mauve']="\e[35m"
      ['lightmauve']="\e[95m"
      ['cyan']="\e[36m"
      ['lightcyan']="\e[96m"
      ['gray']="\e[2m"
      ['lightgray']="\37[1m"
      ['darkgray']="\e[90m"
      ['white']="\e[97m"
    )

    format_end="\e[0m"

    str=""

    for color in "${!colors[@]}";do
      if [[ "$(flag "color" "c")" == "${color}" ]];then
        str+="${colors[$color]}"
        break
      fi
    done

    has_min_one_format=false
    for format in "${!formats[@]}";do
      if [[ "$(flag "${format}")" == true ]];then
        has_min_one_format=true

        str+="${formats[$format]}"
      fi
    done

    text="$(flag "text" "t")"

    if [[ "${text}" != false ]];then
      str+="${text}"
    fi

    if [[ $has_min_one_format == true ]];then
      str+="${format_end}"
    fi

    echo -e "${str}"
}

function framework_title() {
  eval "$(framework_flag)"

  if [[ "${SUDO_PASSWD}" == "" ]];then
    framework_error_message "La variable d'environement \"SUDO_PASSWD\" doit être définie";
    return;
  fi

  if [[ ! -f "/usr/bin/figlet" ]];then
  #    Man of figlet : http://www.figlet.org/figlet-man.html
    echo "${SUDO_PASSWD}" | sudo -S apt install -y figlet 2> /dev/null
  fi

  mkdir -p "${HOME}/aliases/fonts"

  line_prefix="$(flag "line_prefix" "lpre")"
  text="$(flag "text" "t")"
  #  For test fonts : https://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
  font="$(flag "font" "f")"
  if [[ "${font}" != false ]];then
    if [[ "${font:0:8}" == "https://" ]] || [[ "${font:0:7}" == "http://" ]];then
      IFS=$'/'
      read -rd '' -a font_parts <<<"$font"
      font_file="${font_parts[-1]}"
      IFS=$'.'
      read -rd '' -a font_file_parts <<<"$font_file"
      font_name="${font_file_parts[0]//%20/_}"

      if [[ ! -f "${HOME}/aliases/fonts/${font_name}.flf" ]];then
        curl -s "${font}" > "${HOME}/aliases/fonts/${font_name}.flf"
      fi

      font="${font_name}"
    elif [[ ! -f "${HOME}/aliases/fonts/${font}.flf" ]];then
      curl -s "http://www.figlet.org/fonts/${font}.flf" > "${HOME}/aliases/fonts/${font}.flf"
    fi
  fi

  command="figlet -w $(tput cols)"

  if [[ "$(flag "center" "c")" != false ]];then
    command+=" -c"
  fi

  if [[ "${font}" != false ]];then
    command+=" -f ${HOME}/aliases/fonts/${font}.flf"
  fi

  command+=" \"${text}\""

  if [[ "$(flag "space-top" "st")" == true ]];then
    echo ""
  fi

  if [[ "${line_prefix}" == false ]];then
    eval "${command}"
  else
    out=$(eval "${command}")
    IFS=$'\n'
    read -rd '' -a lines <<<"$out"

    for line in "${lines[@]}";do
      echo "${line_prefix}${line}"
    done
  fi

  if [[ "$(flag "space-bottom" "sb")" == true ]];then
    echo ""
  fi
}

function framework_figlet_font_path() {
  echo "https://unpkg.com/figlet@1.4.0/fonts/${1^}.flf"
}

function framework_max_str_width() {
    str=$1
    IFS=$'\n'
    read -rd '' -a lines <<<"$str"
    max_width=0
    for line in "${lines[@]}";do
      if [[ ${#line} -gt $max_width ]];then
        max_width=${#line}
      fi
    done

    echo "${max_width}"
}

function framework_sub_command() {
  eval "$(framework_flag)"

  command="$(flag "name" "n")"
  if [[ "${command}" == false ]];then
    framework_error_message "Vous devez spécifier le nom !"
    return;
  fi
  command_short="$(flag "short" "s")"

  echo "
  if [[ \${#commands[@]} -eq 0 ]];then
    declare -a commands=()
  fi

  commands+=(\"${command}\")"

  if [[ "${command_short}" != false ]];then
    echo "  commands+=(\"${command_short}\")

  if [[ \${#shorts[@]} -eq 0 ]];then
    declare -A shorts=()
  fi

  shorts+=([${command_short//:/_}]=\"${command//:/_}\")
    "
  fi

  func="$(flag "func" "f")"
  if [[ "${func}" != false ]];then
    regex="function ([a-zA-Z_0-9-]+)\(\) \{.*\}"
    if [[ $func =~ $regex ]]; then
      eval "${func}"
    else
      eval "
      function ${command//:/_}() {
        ${func}
      }
      "
    fi
  fi
}

function framework_run() {
  eval "$(framework_flag)"

  echo "
  eval \"\$(framework_generate_shorts_commands)\"
  "

  except_logo_flag="$(flag "except-logo" "el")"
  if [[ "$(flag "with-help" "wh")" == true ]];then
    echo "
    eval \"\$(framework_command_checker --with-help --except-logo \"${except_logo_flag}\")\"
    "
  else
    echo "
    eval \"\$(framework_command_checker --except-logo \"${except_logo_flag}\")\"
    "
  fi

  error="$(flag "error" "err")"
  if [[ "${error}" != false ]];then
    echo "
    eval \"\$(framework_run_command --error \"${error}\")\"
    "
  else
    echo "
  #  Message d'erreur par default : \"command \\\"cmd \${chosen_command}\\\" not found\"
    eval \"\$(framework_run_command)\"
    "
  fi
}

function __() {
  local lang
  lang=$(echo "$(locale | grep LANG=)" | sed 's/LANG=//; s/.UTF-8//')

  if [ -n "${trad[*]}" ] && [ "${trad["$1-$lang"]}" != "" ]; then
    echo "${trad["$1-$lang"]}"
  else
    echo "$1"
  fi
}

function timestamp() {
    date +%s
}

function framework() {
  eval "$(framework_flag)"

  function logo() {
    title="Framework"
    title_font_family="block"
    framework_title --text "${title}" --font "${title_font_family}" --line_prefix "  " -st
  }

  logo

  function help() {
    commands_lines=(
      "framework_flag"
      "➡️  Génère une fonction `flag` avec la signature suivante : flag \"nom long\" \"nom court optionel\""
      ""
      "framework_command_checker [--with-help]"
      "➡️  Génère le code bash permétant de vérifier que le sous alias saisis est valide est à été déclaré"
      ""
      "framework_generate_shorts_commands"
      "➡️  Génère les fonctions de l'alias short en fonction de la fonction de l'alias long."
      ""
      "framework_success_message \"message\""
      "➡️  Affiche un message avec un tick vert devant"
      ""
      "framework_is_success_message \"message\""
      "➡️  Vérifie que le message à pour premier charactère un tick vert"
      ""
      "framework_warning_message \"message\""
      "➡️  Affiche un message avec un panneau attention orange devant"
      ""
      "framework_is_warning_message \"message\""
      "➡️  Vérifie que le message à pour premier charactère un panneau attention orange"
      ""
      "framework_error_message \"message\""
      "➡️  Affiche un message avec une croix rouge devant"
      ""
      "framework_is_error_message \"message\""
      "➡️  Vérifie que le message à pour premier charactère une croix rouge"
      ""
      "framework_generate_doc reference_de_tableau"
      "➡️  Mise en forme d'une liste destiné à de la documentation"
      ""
      "framework_link \"url|local_path\" \"label\""
      "➡️  Formatte le texte pour qu'il soit clickable via ctrl+click avec une url ou un chemin local donné."
      ""
      "framework_format --text|-t content [--underline] [--weight] [--color|-c \"default|black|white|red|lightred|green|lightgreen|yellow|lightyellow|blue|lightblue|purple|lightpurple|cyan|lightcyan|gray|lightgray|darkgray\"]"
      ""
      "framework_figlet_font_path \"font_name\""
      "➡️  Génère l'url de téléchargement d'une font figlet via sont nom"
      ""
      "framework_max_str_width \"multilines_str\""
      "➡️  Donne la largeur maximal d'une chaine multi-lignes"
      ""
      "framework_sub_command --name|-n sub_command_name --short|-s short_sub_command_name"
      "➡️  Cette fonction est appelé après la définition d'une fonction que l'on utilisera en sous alias"
      "➡️  Les caractères \":\" dans l'alias seront remplacés par \"_\" dans le nom de la fonction et dans le nom du short."
      ""
      "framework_run [--with-help] [--error|-err \"error message\"]"
      "➡️  Lance les fonctions suivantes de manière regroupées dans cet ordre :"
      "  1. framework_generate_shorts_commands"
      "  2. framework_command_checker [--with-help]"
      "  3. framework_run_command [--error default=\"\"command \\\"alwaysdata \${chosen_command}\\\" not found\"\"]"
      ""
      "__ \"message\""
      "➡️  Récupère la valeur associée à la cle de traduction \"message\""
      "et à la langue du systeme définie dans un tableau \"trad\" dans une fonction appelante."
      ""
      "timestamp"
      "➡️  Donne la date courrente sous forme de timestamp"
      ""
      "framework tools:sites:list"
      "⬆️  framework tools:s:l"
    )

    framework_create_help "framework" "${commands_lines[@]}"
  }
  eval "$(framework_sub_command -n "help")"

  function tools_sites_list() {
    list=(
      "- Figlet"
      "Liste des fonts=https://devhints.io/figlet"
    )

    framework_warning_message "$(framework_format --weight -t "La liste ci-dessous est clickable (ctrl-click)")"
    echo ""

    window_length=$(tput cols)
    cmp=0
    for line in "${list[@]}";do
      if [[ "${line:0:2}" == "- " ]];then
        [[ $cmp -gt 0 ]] && echo ""
        width=80
        [[ 80 -gt $window_length ]] && width=$window_length

        left="|= "
        right=" =|"

        title="$(framework_format --underline -t "${line:2:$((${#line} - 2))}")"

        left_limit=$((((width / 2) - (${#title} / 2)) - 1))
        [[ ! "$(echo "scale=2; ${#title}/2" | bc)" =~ .5 ]] && left_limit=$((left_limit+1))

        left_part="${left}"
        for ((i=0; i<left_limit;i++));do
          left_part+="="
        done

        right_part=""
        for ((i=0; i<$((((width / 2) - (${#title} / 2)) - 1));i++));do
          right_part+="="
        done
        right_part+="${right}"

        echo "${left_part} $(framework_format --underline -t "${line:2:$((${#line} - 2))}") ${right_part}"
        echo ""
        continue
      fi

      if [[ "${line}" =~ "=" ]];then
        IFS=$'='
        read -rd '' -a parts <<<"${line}"
        echo -n " • $(framework_link "${parts[1]}" "$(framework_format --underline -t "${parts[0]}")")"
        echo ""
      else
        echo -n " • $(framework_link "${line}")"
      fi

      cmp=$((cmp+1))
    done
  }
  eval "$(framework_sub_command -n "tools:sites:list" -s "tools:s:l")"

  eval "$(framework_run --with-help)"
}