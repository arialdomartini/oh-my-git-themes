: ${omg_ungit_prompt:=$PS1}

: ${omg_is_a_git_repo_symbol:=''}
: ${omg_has_untracked_files_symbol:=''}        #                ?    
: ${omg_has_adds_symbol:=''}
: ${omg_has_deletions_symbol:=''}
: ${omg_has_cached_deletions_symbol:=''}
: ${omg_has_modifications_symbol:=''}
: ${omg_has_cached_modifications_symbol:=''}
: ${omg_ready_to_commit_symbol:=''}            #   →
: ${omg_is_on_a_tag_symbol:=''}
: ${omg_needs_to_merge_symbol:='ᄉ'}
: ${omg_detached_symbol:=''}
: ${omg_can_fast_forward_symbol:=''}
: ${omg_has_diverged_symbol:=''}               #   
: ${omg_not_tracked_branch_symbol:=''}
: ${omg_should_sync_symbol:=''}                #     
: ${omg_rebase_tracking_branch_symbol:=''}     #   
: ${omg_merge_tracking_branch_symbol:=''}      #  
: ${omg_should_push_symbol:=''}                #    
: ${omg_has_stashes_symbol:=''}



# Flags
omg_default_color_on=$WHITE
omg_default_color_off=$WHITE
reset='%{$reset_color%}'

CC_CURRENT_PATH="~"
CC_CURRENT_USERNAME="%n"
CC_CURRENT_HOSTNAME="%m"
CC_TIME_AND_DATE="%D{%H:%M:%S} $CC_SYMBOL_CALENDAR %D{%Y-%m-%d}"

reset="%{\e[0m%}"

#colors
autoload -U colors && colors

PROMPT='$(build_prompt)'
RPROMPT='%{$reset_color%}%T %{$fg_bold[white]%} %n@%m%{$reset_color%}'

function enrich_append {
    local flag=$1
    local symbol=$2
    local color=${3:-$omg_default_color_on}
    if [[ $flag == false ]]; then symbol=' '; fi

    echo -n "${color}${symbol}  "
}

function custom_build_prompt {
    local enabled=${1}
    local current_commit_hash=${2}
    local is_a_git_repo=${3}
    local current_branch=$4
    local detached=${5}
    local just_init=${6}
    local has_upstream=${7}
    local has_modifications=${8}
    local has_modifications_cached=${9}
    local has_adds=${10}
    local has_deletions=${11}
    local has_deletions_cached=${12}
    local has_untracked_files=${13}
    local ready_to_commit=${14}
    local tag_at_current_commit=${15}
    local is_on_a_tag=${16}
    local has_upstream=${17}
    local commits_ahead=${18}
    local commits_behind=${19}
    local has_diverged=${20}
    local should_push=${21}
    local will_rebase=${22}
    local has_stashes=${23}

    local prompt=""
    local original_prompt=$PS1

    if [[ $is_a_git_repo == true ]]; then
        # on filesystem
        prompt="%K{white}%F{black} "
        prompt+=$(enrich_append $is_a_git_repo $omg_is_a_git_repo_symbol "%K{white}%F{black}")
        prompt+=$(enrich_append $has_stashes $omg_has_stashes_symbol "%K{white}%F{yellow}")

        prompt+=$(enrich_append $has_untracked_files $omg_has_untracked_files_symbol "%K{white}%F{red}")
        prompt+=$(enrich_append $has_modifications $omg_has_modifications_symbol "%K{white}%F{red}")
        prompt+=$(enrich_append $has_deletions $omg_has_deletions_symbol "%K{white}%F{red}")
        

        # ready
        prompt+=$(enrich_append $has_adds $omg_has_adds_symbol "%K{white}%F{black}")
        prompt+=$(enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "%K{white}%F{black}")
        prompt+=$(enrich_append $has_deletions_cached $omg_has_cached_deletions_symbol "%K{white}%F{black}")
        
        # next operation

        if [[ $has_diverged == true || $commits_behind -gt 0 ]]; then
            local should_sync=true
        fi
        prompt+=$(enrich_append $ready_to_commit $omg_ready_to_commit_symbol "%K{white}%F{red}")
        prompt+=$(enrich_append $should_sync ${omg_should_sync_symbol} "%K{white}%F{red}")

        # where

        prompt="${prompt} %F{white}%K{red} %K{red}%F{black}"
        if [[ $detached == true ]]; then
            prompt+=$(enrich_append $detached $omg_detached_symbol "%K{red}%F{black}")
            prompt+=$(enrich_append $detached "(${current_commit_hash:0:7})" "%K{red}%F{white}")
        else            
            if [[ $has_upstream == false ]]; then
                prompt+=$(enrich_append true "-- ${omg_not_tracked_branch_symbol}  --  (${current_branch})" "%K{red}%F{black}")
            else
                if [[ $will_rebase == true ]]; then
                    local type_of_upstream=$omg_rebase_tracking_branch_symbol
                else
                    local type_of_upstream=$omg_merge_tracking_branch_symbol
                fi

                if [[ $has_diverged == true ]]; then
                    prompt+=$(enrich_append true "-${commits_behind} ${omg_has_diverged_symbol} +${commits_ahead}" "%K{red}%F{white}")
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        prompt+=$(enrich_append true "-${commits_behind} ${omg_can_fast_forward_symbol} --" "%K{red}%F{black}")
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        prompt+=$(enrich_append true "-- ${omg_should_push_symbol}  +${commits_ahead}" "%K{red}%F{black}")
                    fi
                    if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
                         prompt+=$(enrich_append true " --   -- " "%K{red}%F{black}")
                    fi
                    
                fi
                prompt+=$(enrich_append true "(${current_branch} ${type_of_upstream} ${upstream//\/$current_branch/})" "%K{red}%F{black}")
            fi
        fi
        prompt+=$(enrich_append ${is_on_a_tag} ${omg_is_on_a_tag_symbol} "%K{red}%F{yellow}")
        prompt+="%F{red}%K{black}%k%f
${CC_CURRENT_PATH}: "
    else
        prompt="${omg_ungit_prompt}"
    fi
 
    echo "${prompt}"
}
