#!/bin/sh
_lazycommit_init() {
    clear

    INIT_PREFIX="Prefixo"
    INIT_TITLE="Título"
    INIT_DESCRIPTION="Descrição"
    INTI_PROBLEM="Problema"
    INIT_SOLUTION="Solução"
    INIT_LINKS="Links"
    INIT_OBSERVATIONS="Observações"
    INIT_BREAKING_CHANGES="Breaking Changes"

    local OPTIONS=()

    if [[ "$PREFIX" == "" ]]; then
        OPTIONS+=("$INIT_PREFIX")
    else
        OPTIONS+=("$INIT_PREFIX (✓)")
    fi

    if [[ "$TITLE" == "" ]]; then
        OPTIONS+=("$INIT_TITLE")
    else
        OPTIONS+=("$INIT_TITLE (✓)")
    fi

    if [[ "$DESCRIPTION" == "" ]]; then
        OPTIONS+=("$INIT_DESCRIPTION")
    else
        OPTIONS+=("$INIT_DESCRIPTION (✓)")
    fi

    if [[ "$PROBLEM" == "" ]]; then
        OPTIONS+=("$INTI_PROBLEM")
    else
        OPTIONS+=("$INTI_PROBLEM (✓)")
    fi

    if [[ "$SOLUTION" == "" ]]; then
        OPTIONS+=("$INIT_SOLUTION")
    else
        OPTIONS+=("$INIT_SOLUTION (✓)")
    fi

    if [[ "$LINKS" == "" ]]; then
        OPTIONS+=("$INIT_LINKS")
    else
        OPTIONS+=("$INIT_LINKS (✓)")
    fi

    if [[ "$OBSERVATIONS" == "" ]]; then
        OPTIONS+=("$INIT_OBSERVATIONS")
    else
        OPTIONS+=("$INIT_OBSERVATIONS (✓)")
    fi

    if [[ "$BREAKING_CHANGES" == "" ]]; then
        OPTIONS+=("$INIT_BREAKING_CHANGES")
    else
        OPTIONS+=("$INIT_BREAKING_CHANGES (✓)")
    fi

    echo -e "LazyCommit\n"
    echo -e "Selecione o campo que deseja adicionar no seu commit:"
    _lazycommit_help "Adicionar: ENTER   |   Sair:  ESC"

    FIELDS=$(gum choose "${OPTIONS[@]}")
    
    grep -q "Prefixo" <<< "$FIELDS" && _lazycommit_prefixo
    grep -q "Título" <<< "$FIELDS" && _lazycommit_titulo
    grep -q "Descrição" <<< "$FIELDS" && _lazycommit_descricao
    grep -q "Problema" <<< "$FIELDS" && _lazycommit_problema
    grep -q "Solução" <<< "$FIELDS" && _lazycommit_solucao
    grep -q "Links" <<< "$FIELDS" && _lazycommit_links
    grep -q "Observações" <<< "$FIELDS" && _lazycommit_observacoes
    grep -q "Breaking Changes" <<< "$FIELDS" && _lazycommit_breaking_changes

    if [ ! -z $FIELDS ]; then
        _lazycommit_init
        clear
        return
    fi

    clear
}

_lazycommit_help(){
    gum style --foreground="#696969" $@
    echo
}

_lazycommit_prefixo() {
    clear
    
    PREFIX=""

    echo -e "LazyCommit\n"
    echo -e "Selecione os prefixos que deseja adicionar no seu commit:"
    _lazycommit_help "Selecionar: SPACE  |  Sair:  ESC"

    PREFIX_BUILD="Builds: Alterações que afetam o sistema de compilação ou dependências externas"
    PREFIX_CICD="Continuous Integration/Delivery: Alterações em nossos arquivos e scripts de configuração de CI/CD"
    PREFIX_DOCS="Documentation: Alterações apenas nas documentações ou comentários"
    PREFIX_FEATURE="Features: Adição de recursos ou funcionalidades"
    PREFIX_FIX="Fix: Correções de bugs ou erros"
    PREFIX_PERF="Performance Improvements: Alterações de código que melhora o desempenho"
    PREFIX_REFACTOR="Code Refactoring: Alterações de código que não corrigem bugs e não adicionam recursos"
    PREFIX_STYLE="Style: Alterações que não afetam o sentido/propósito do código"
    PREFIX_TEST="Tests: Adicão ou correção de testes"
    PREFIX_CHORE="Chore: Alterações que não modificam arquivos da aplicação ou de testes"
    PREFIX_REVERT="Revert: Reverte um commit anterior"

    PREFIX_FIELDS=$(gum choose --height=11 --cursor-prefix "[ ] " --selected-prefix "[✓] " --no-limit "$PREFIX_BUILD" "$PREFIX_CICD" "$PREFIX_DOCS" "$PREFIX_FEATURE" "$PREFIX_FIX" "$PREFIX_PERF" "$PREFIX_REFACTOR" "$PREFIX_STYLE" "$PREFIX_TEST" "$PREFIX_CHORE" "$PREFIX_REVERT")

    local PREFIX_ARRAY=()

    grep -q "$PREFIX_BUILD" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("BUILD")
    grep -q "$PREFIX_CICD" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("CICD")
    grep -q "$PREFIX_DOCS" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("DOCS")
    grep -q "$PREFIX_FEATURE" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("FEAT")
    grep -q "$PREFIX_FIX" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("FIX")
    grep -q "$PREFIX_PERF" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("PERF")
    grep -q "$PREFIX_REFACTOR" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("REFACT")
    grep -q "$PREFIX_STYLE" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("STYLE")
    grep -q "$PREFIX_TEST" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("TEST")
    grep -q "$PREFIX_CHORE" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("CHORE")
    grep -q "$PREFIX_REVERT" <<< "$PREFIX_FIELDS" && PREFIX_ARRAY+=("REVERT")

    if [ -z "$PREFIX_ARRAY" ]; then
        PREFIX=""
        return
    fi

    PREFIX+="[ "
    for VALUE in "${PREFIX_ARRAY[@]}"
    do
        PREFIX+="$VALUE"
        if [[ "$VALUE" == "${PREFIX_ARRAY[-1]}" ]]; then
            PREFIX+=" ]"
        else
            PREFIX+=" | "
        fi
    done
}

_lazycommit_titulo() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite o título do seu commit:"
    _lazycommit_help "Concluir: ENTER  |  Sair: ESC"

    local TITLE_FIELD=""
    local TITLE_VALUE=$TITLE
    TITLE=""

    TITLE_FIELD=$(gum input --width=80 --value="$TITLE_VALUE")

    if [ -z "$TITLE_FIELD" ]; then
        TITLE=""
        return
    fi

    TITLE="$TITLE_FIELD"
}

_lazycommit_descricao() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite a descrição do seu commit:"
    _lazycommit_help "Concluir: ESC"

    local DESCRIPTION_FIELD=""
    local DESCRIPTION_VALUE=$DESCRIPTION
    DESCRIPTION=""

    DESCRIPTION_FIELD=$(gum write --placeholder="..." --value="$DESCRIPTION_VALUE" --width=80 --prompt="┃ " --show-cursor-line)

    if [ -z "$DESCRIPTION_FIELD" ]; then
        DESCRIPTION=""
        return
    fi

    DESCRIPTION="$DESCRIPTION_FIELD"
}

_lazycommit_problema() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite o problema que o commit está resolvendo:"
    _lazycommit_help "Concluir: ESC"

    local PROBLEM_FIELD=""
    local PROBLEM_VALUE=$PROBLEM
    PROBLEM=""

    PROBLEM_FIELD=$(gum write --placeholder="..." --value="$PROBLEM_VALUE" --width=80 --prompt="┃ " --show-cursor-line)

    if [ -z "$PROBLEM_FIELD" ]; then
        PROBLEM=""
        return
    fi

    PROBLEM="$PROBLEM_FIELD"
}

_lazycommit_solucao() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite a solução que o commit está implementando:"
    _lazycommit_help "Concluir: ESC"

    local SOLUTION_FIELD=""
    local SOLUTION_VALUE=$SOLUTION
    SOLUTION=""

    SOLUTION_FIELD=$(gum write --placeholder="..." --value="$SOLUTION_VALUE" --width=80 --prompt="┃ " --show-cursor-line)

    if [ -z "$SOLUTION_FIELD" ]; then
        SOLUTION=""
        return
    fi

    SOLUTION="$SOLUTION_FIELD"
}

_lazycommit_links() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite os links que o commit está relacionado:"
    _lazycommit_help "Concluir: ESC"

    local LINKS_FIELD=""
    local LINKS_VALUE=$LINKS
    LINKS=""

    LINKS_FIELD=$(gum write --placeholder="..." --value="$LINKS_VALUE" --width=80 --prompt="┃ " --show-cursor-line)

    if [ -z "$LINKS_FIELD" ]; then
        LINKS=""
        return
    fi

    LINKS="$LINKS_FIELD"
}

_lazycommit_observacoes() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite as observações do commit:"
    _lazycommit_help "Concluir: ESC"

    local OBSERVATIONS_FIELD=""
    local OBSERVATIONS_VALUE=$OBSERVATIONS
    OBSERVATIONS=""

    OBSERVATIONS_FIELD=$(gum write --placeholder="..." --value="$OBSERVATIONS_VALUE" --width=80 --prompt="┃ " --show-cursor-line)

    if [ -z "$OBSERVATIONS_FIELD" ]; then
        OBSERVATIONS=""
        return
    fi

    OBSERVATIONS="$OBSERVATIONS_FIELD"
}

_lazycommit_breaking_changes() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Digite as mudanças que quebram a compatibilidade:"
    _lazycommit_help "Concluir: ESC"

    local BREAKING_CHANGES_FIELD=""
    local BREAKING_CHANGES_VALUE=$BREAKING_CHANGES
    BREAKING_CHANGES=""

    BREAKING_CHANGES_FIELD=$(gum write --placeholder="..." --value="$BREAKING_CHANGES_VALUE" --width=80 --prompt="┃ " --show-cursor-line)

    if [ -z "$BREAKING_CHANGES_FIELD" ]; then
        BREAKING_CHANGES=""
        return
    fi

    BREAKING_CHANGES="$BREAKING_CHANGES_FIELD"
}

_lazycommit_proceed_to_commit() {
    clear

    echo -e "LazyCommit\n"
    echo -e "Confirme o commit:\n"
    echo -e "----------------------------------------\n"

    local COMMIT_MESSAGE=""

    if [[ "$PREFIX" != "" ]]; then
        COMMIT_MESSAGE+="$PREFIX "
    fi

    if [[ "$TITLE" != "" ]]; then
        COMMIT_MESSAGE+="$TITLE\n\n"
    fi

    if [[ "$DESCRIPTION" != "" ]]; then
        COMMIT_MESSAGE+="Descrição:\n\n$DESCRIPTION\n\n"
    fi

    if [[ "$PROBLEM" != "" ]]; then
        COMMIT_MESSAGE+="Problema:\n\n$PROBLEM\n\n"
    fi

    if [[ "$SOLUTION" != "" ]]; then
        COMMIT_MESSAGE+="Solução:\n\n$SOLUTION\n\n"
    fi

    if [[ "$LINKS" != "" ]]; then
        COMMIT_MESSAGE+="Links:\n\n$LINKS\n\n"
    fi

    if [[ "$OBSERVATIONS" != "" ]]; then
        COMMIT_MESSAGE+="Observações:\n\n$OBSERVATIONS\n\n"
    fi

    if [[ "$BREAKING_CHANGES" != "" ]]; then
        COMMIT_MESSAGE+="Quebra de compatibilidade:\n\n$BREAKING_CHANGES\n\n"
    fi

    echo $COMMIT_MESSAGE
    echo "\n----------------------------------------"

    gum confirm "Confirma? [Não]" --affirmative "Sim" --negative "Não" --default=false && CONFIRM_COMMIT=true

    if $CONFIRM_COMMIT; then
        git commit -e -m "$(echo $COMMIT_MESSAGE)" && ( clear; echo "$(git log -1 --stat --pretty=oneline | head -n 1 && git log -1 --stat --pretty=oneline | tail -n 1)" ) || (clear; echo "Erro ao realizar o commit" )
        echo -e "\n\nPressione qualquer tecla para continuar..."
        read -n 1
        return
    fi

    LOOP=true
}

_lazycommit(){
    _lazycommit_check_gum
    _lazycommit_check_git_dir

    PREFIX=""
    TITLE=""
    DESCRIPTION=""
    PROBLEM=""
    SOLUTION=""
    LINKS=""
    OBSERVATION=""
    BREAKING_CHANGES=""

    CONFIRM_COMMIT=false
    LOOP=true

    while $LOOP; do
        clear
        _lazycommit_init
        clear

        if [[ "$PREFIX" == "" && "$TITLE" == "" && "$DESCRIPTION" == "" && "$PROBLEM" == "" && "$SOLUTION" == "" && "$LINKS" == "" && "$OBSERVATION" == "" && "$BREAKING_CHANGES" == "" ]]; then
            break
        fi

        echo -e "LazyCommit\n"
        gum confirm "Proseguir para o commit? [Não]" --affirmative "Sim" --negative "Não" --default=false && LOOP=false

        if ! $LOOP; then
            _lazycommit_proceed_to_commit
        fi

        if ! $CONFIRM_COMMIT; then
            clear
            echo -e "LazyCommit\n"
            gum confirm "Sair? [Não]" --affirmative "Sim" --negative "Não" --default=false && break
        fi
    done
    clear
}

_lazycommit_check_gum() {
    if ! command -v gum &> /dev/null
    then
        echo "gum could not be found"
        exit
    fi
}

_lazycommit_check_git_dir() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null
    then
        echo "Not a git repository"
        exit
    fi
}