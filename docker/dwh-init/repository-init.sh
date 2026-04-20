#!/bin/bash

set -euo pipefail


# ---------------------------------------------------------------------------- #
#                          1. Вспомогательные функции                          #
# ---------------------------------------------------------------------------- #

get_group_id() {
  # Получение id группы в gitlab
  local path="$1"
  local parent_id="$2"

  local url="${GITLAB_URL}/api/v4/groups?search=${path}"
  local jq_filter

  if [[ -z "${parent_id}" ]]; then
    jq_filter=".[] | select(.path==\"${path}\" and (.parent_id == null)) | .id"
  else
    jq_filter=".[] | select(.path==\"${path}\" and .parent_id == ${parent_id}) | .id"
  fi

  curl -sS --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" "${url}" \
    | jq -r "${jq_filter}" | head -n1
}

create_group() {
  # Создание группы в gitlab
  local name="$1"
  local path="$2"
  local parent_id="$3"

  local data
  if [[ -z "${parent_id}" ]]; then
    data=$(jq -n --arg name "$name" --arg path "$path" \
      '{name: $name, path: $path}')
  else
    data=$(jq -n --arg name "$name" --arg path "$path" --argjson pid "$parent_id" \
      '{name: $name, path: $path, parent_id: $pid}')
  fi

  curl -sS --request POST \
    --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "${data}" \
    "${GITLAB_URL}/api/v4/groups" \
    | jq -r '.id'
}

create_project() {
  # Создание пустого проекта в gitlab
  local project_name="$1"
  local namespace_id="$2"

  jq -n --arg name "$project_name" --arg path "$project_name" --argjson ns "$namespace_id" \
    '{name: $name, path: $path, namespace_id: $ns}' \
  | curl -sS --request POST \
      --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
      --header "Content-Type: application/json" \
      --data @- \
      "${GITLAB_URL}/api/v4/projects" \
  | jq -r '.id'
}

is_project_empty() {
  # Определение пустой ли проект или нет
  local project_id="$1"

  # Берём объект проекта и смотрим поле empty_repo
  local flag
  flag=$(curl -sS --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${project_id}" \
    | jq -r '.empty_repo')

  # empty_repo == true → репозиторий реально пустой
  if [[ "${flag}" == "true" ]]; then
    return 0   # пустой
  else
    return 1   # не пустой
  fi
}

# ---------------------------------------------------------------------------- #
#                      2. Функции работы с пользователями                      #
# ---------------------------------------------------------------------------- #

# Найти GitLab user ID по username
get_user_id_by_username() {
  local username="$1"

  local id
  id=$(curl -sS --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        "${GITLAB_URL}/api/v4/users?username=${username}" \
        | jq -r '.[0].id' 2>/dev/null)

  if [[ -n "${id}" && "${id}" != "null" ]]; then
    echo "${id}"
    return 0
  fi

  return 1
}

# Проверить, есть ли пользователь в группе
user_is_group_member() {
  local group_id="$1"
  local user_id="$2"

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" \
    --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
    "${GITLAB_URL}/api/v4/groups/${group_id}/members/${user_id}" || echo "000")

  [[ "${status}" == "200" ]]
}

# Добавить пользователя в группу как Reporter (20)
# add_user_to_group_reporter() {
#   local group_id="$1"
#   local user_id="$2"

#   curl -sS --request POST \
#     --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
#     --data "user_id=${user_id}&access_level=20" \
#     "${GITLAB_URL}/api/v4/groups/${group_id}/members" >/dev/null
# }

# Универсальная функция: добавить пользователя в группу с заданным access_level
add_user_to_group() {
    local group_id="$1"
    local user_id="$2"
    local access_level="$3"
    
    curl -sS --request POST \
        --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        --data "user_id=${user_id}&access_level=${access_level}" \
        "${GITLAB_URL}/api/v4/groups/${group_id}/members" >/dev/null
}

# Обход пользователей из YAML (выводит username по одному в строке)
iterate_usernames_from_yaml() {
  local file="$1"

  if ! command -v yq >/dev/null 2>&1; then
    echo "WARNING: yq не найден, пропускаю YAML ${file}" >&2
    return 1
  fi

  yq '.[] | .username' "${file}"
}

# Обход пользователей из CSV (выводит username по одному в строке)
iterate_usernames_from_csv() {
  local file="$1"

  if ! command -v awk >/dev/null 2>&1; then
    echo "WARNING: awk не найден, пропускаю CSV ${file}" >&2
    return 1
  fi

  # Пропускаем заголовок, берём первый столбец username
  awk -F',' 'NR>1 { gsub(/\r/,"",$1); print $1 }' "${file}"
}

# Универсальная функция: добавить всех пользователей в группу
# add_all_users_to_group() {
#   local group_id="$1"
#   local access_level="${2:-20}"  # По умолчанию Reporter (20)

#   [[ -z "${USERS_SOURCE:-}" ]] && return 0

#   echo "Добавление пользователей из ${USERSSOURCE} в группу ID=${group_id} (access_level=${access_level})..."

#   local count=0
#   local usernames

#   case "${USERS_SOURCE}" in
#     yaml)
#       usernames=$(iterate_usernames_from_yaml "${USERS_YAML}" || true)
#       ;;
#     csv)
#       usernames=$(iterate_usernames_from_csv "${USERS_CSV}" || true)
#       ;;
#     *)
#       echo "  Неизвестный источник пользователей: ${USERS_SOURCE}, пропуск" >&2
#       return 0
#       ;;
#   esac

#   if [[ -z "${usernames}" ]]; then
#     echo "  В источнике ${USERS_SOURCE} пользователей не найдено или ошибка чтения"
#     return 0
#   fi

#   # Проходим по username'ам
#   while IFS= read -r username; do
#     username="${username//\"/}"
#     echo "[DEBUG]: Обработка пользователя ${username}"
#     [[ -z "${username}" || "${username}" == "null" ]] && continue

#     local uid
#     if ! uid=$(get_user_id_by_username "${username}"); then
#       echo "    Пользователь ${username} не найден в GitLab, пропуск"
#       continue
#     fi

#     if user_is_group_member "${group_id}" "${uid}"; then
#       echo "    Пользователь ${username} (ID=${uid}) уже в группе, пропуск"
#       continue
#     fi

#     add_user_to_group_reporter "${group_id}" "${uid}" "$access_level"
#     echo "Добавлен пользователь ID=${uid} ('$username') в группу ${group_id} с уровнем (${access_level})"
#     count=$((count+1))
#   done <<< "${usernames}"

#   echo "  Добавление пользователей завершено, новых добавлено: ${count}"
# }

# Добавить одного пользователя в группу/проект
add_user_to_entity() {
    local entity_id="$1"
    local user_id="$2"
    local access_level="$3"
    local entity_type="${4:-group}"
    
    local api_path="/api/v4"
    [[ "$entity_type" == "project" ]] && api_path="${api_path}/projects"
    
    curl -sS --request POST \
        --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        --data "user_id=${user_id}&access_level=${access_level}" \
        "${GITLAB_URL}${api_path}/${entity_id}/members" >/dev/null
}

# Проверка членства (нужна для избежания дублей)
user_is_entity_member() {
    local entity_id="$1"
    local user_id="$2"
    local entity_type="${3:-group}"
    
    local api_path="/api/v4"
    [[ "$entity_type" == "project" ]] && api_path="${api_path}/projects"
    
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" \
        --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        "${GITLAB_URL}${api_path}/${entity_id}/members/${user_id}")
    
    [[ "$status" == "200" ]]
}

# Универсальная: добавить всех пользователей в группу/проект
# $1: ID (group_id или project_id)
# $2: access_level (20=Reporter, 40=Maintainer)
# $3: type (group|project, по умолчанию group)
add_all_users_to_entity() {
    local entity_id="$1"
    local access_level="${2:-20}"
    local entity_type="${3:-group}"
    
    [[ -z "${USERSSOURCE:-}" ]] && return 0
    
    local api_path="/api/v4"
    [[ "$entity_type" == "project" ]] && api_path="${api_path}/projects"
    
    echo "Добавление пользователей из ${USERSSOURCE} в ${entity_type} ID=${entity_id} (access_level=${access_level})..."
    
    local count=0
    local usernames
    case "${USERSSOURCE}" in
        yaml) usernames=$(iterate_usernames_from_yaml "${USERSYAML}") ;;
        csv) usernames=$(iterate_usernames_from_csv "${USERSCSV}") ;;
        *) echo "Неизвестный USERSSOURCE"; return 1 ;;
    esac
    
    [[ -z "$usernames" ]] && { echo "Нет пользователей"; return 0; }
    
    while IFS= read -r username; do
        username=$(echo "$username" | xargs)
        [[ -z "$username" || "$username" == null ]] && continue
        
        local uid
        uid=$(get_userid_by_username "$username") || {
            echo "Пользователь '$username' не найден, пропуск" >&2
            continue
        }
        
        # Проверка членства (адаптировать под project если нужно)
        if user_is_entity_member "$entity_id" "$uid" "$entity_type"; then
            echo "Пользователь '$username' (ID=$uid) уже в ${entity_type}, пропуск"
            continue
        fi
        
        add_user_to_entity "$entity_id" "$uid" "$access_level" "$entity_type"
        echo "Добавлен '$username' (ID=$uid) в ${entity_type} ${entity_id}"
        ((count++))
    done <<< "$usernames"
    
    echo "Добавлено: $count пользователей"
}



# ---------------------------------------------------------------------------- #
#                               3. Основной цикл                               #
# ---------------------------------------------------------------------------- #
# for full in "${PROJECTS[@]}"; do
# local access_level=20  # По умолчанию Reporter
for full in "${!PROJECTS[@]}"; do
  echo
  echo "==== Обработка ${full} ===="

  # Убираем .git
  path_no_git="${full%.git}"

  # Разбиваем на части
  IFS="/" read -r -a PARTS <<< "${path_no_git}"

  # Последний элемент — имя проекта
  PROJECT_NAME="${PARTS[-1]}"

  # Все предыдущие — цепочка групп
  unset 'PARTS[-1]'
  GROUP_PARTS=("${PARTS[@]}")

  echo "Группы: ${GROUP_PARTS[*]:-<нет>}"
  echo "Проект: ${PROJECT_NAME}"

  # Создаём/находим группы
  parent_id=""
  for part in "${GROUP_PARTS[@]}"; do
    [[ -z "$part" ]] && continue

    name="$part"
    path="$part"

    echo "-- Обрабатываем группу: ${path} (parent_id=${parent_id:-none})"

    gid=$(get_group_id "${path}" "${parent_id}" || true)

    if [[ -z "${gid}" ]]; then
      echo "   Группа не найдена, создаю..."
      gid=$(create_group "${name}" "${path}" "${parent_id}")
      if [[ "${gid}" == "null" || -z "${gid}" ]]; then
        echo "   Не удалось создать группу ${path}" >&2
        exit 1
      fi
      echo "   Создана группа ID=${gid}"
    else
      echo "   Группа уже существует, ID=${gid}"
    fi

    parent_id="${gid}"
  done

  FINAL_GROUP_ID="${parent_id}"

  if [[ -z "${FINAL_GROUP_ID}" ]]; then
    echo "   Не удалось определить конечную группу для ${full}" >&2
    exit 1
  fi

  echo "Итоговая группа ID=${FINAL_GROUP_ID}"

  # Добавляем всех пользователей из users.yml/csv в эту группу как Reporter
  # add_all_users_to_group "${FINAL_GROUP_ID}" 20  # Reporter для группы
  add_all_users_to_entity "${FINAL_GROUP_ID}" 20 "group"

  # Определяем роль для пользователей: Maintainer (40) или Reporter (20)
  # for maint_proj in "${MAINTAINER_PROJECTS[@]}"; do
  #     if [[ "$PROJECTNAME" == "$maint_proj" ]]; then
  #         access_level=40  # Maintainer
  #         break
  #     else
  #         access_level=20
  #     fi
  # done

  # Добавляем пользователей с нужными правами
  # add_all_users_to_group "${FINAL_GROUP_ID}" "$access_level"
  # echo "Добавлены пользователи в группу ${FINAL_GROUP_ID} с правами $([[ $access_level == 40 ]] && echo 'Maintainer' || echo 'Reporter')"


  PROJECT_ID=""
  # Ищем проект по пути и группе
  PROJECT_ID=$(curl -sS --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
    "${GITLAB_URL}/api/v4/groups/${FINAL_GROUP_ID}/projects" \
    | jq -r ".[] | select(.path==\"${PROJECT_NAME}\") | .id" || true)

  if [[ "${MODE}" == "--force" && -n "${PROJECT_ID}" ]]; then
    echo "Режим FORCE: удаляю существующий проект ID=${PROJECT_ID} (${path_no_git}.git)..."
    curl -sS --request DELETE \
      --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
      "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}" >/dev/null

    PROJECT_ID=""
  fi

  if [[ -z "${PROJECT_ID}" ]]; then
    echo "Создаю проект ${PROJECT_NAME} в группе ${FINAL_GROUP_ID}..."
    PROJECT_ID=$(create_project "${PROJECT_NAME}" "${FINAL_GROUP_ID}")
    if [[ "${PROJECT_ID}" == "null" || -z "${PROJECT_ID}" ]]; then
      echo "Не удалось создать проект ${PROJECT_NAME}" >&2
      exit 1
    fi

    # Если проект требует Maintainer — добавляем пользователей в проект с правами 40
    # if [[ " ${MAINTAINER_PROJECTS[*]} " =~ " ${PROJECT_NAME} " ]]; then
    #     echo "Проект ${PROJECT_NAME} требует Maintainer (40)"
    #     add_all_users_to_project "${PROJECT_ID}" 40
    # else
    #     echo "Проект ${PROJECT_NAME}: Reporter (20) для группы достаточно"
    # fi
    if [[ " ${MAINTAINER_PROJECTS[*]} " =~ " ${PROJECT_NAME} " ]]; then
      add_all_users_to_entity "${PROJECT_ID}" 40 "project"
    fi
    echo "Проект создан, ID=${PROJECT_ID}"
  else
    echo "Проект уже существует, ID=${PROJECT_ID}"

    if [[ "${MODE}" == "safe" ]]; then
      echo "Проверяю, пустой ли репозиторий..."

      if is_project_empty "${PROJECT_ID}"; then
        echo "Репозиторий пустой — можно заливать код."
      else
        echo "Репозиторий НЕ пустой — в режиме SAFE пропускаем заливку."
        # переходим к следующему проекту
        continue
      fi
    fi
  fi

  # Работа с архивом ./projects/project-name.tar.gz
  ARCHIVE_PATH="${ARCHIVE_DIR}/${PROJECT_NAME}.tar.gz"
  if [[ ! -f "${ARCHIVE_PATH}" ]]; then
    echo "Архив ${ARCHIVE_PATH} не найден, пропуск" >&2
    continue
  fi

  WORKDIR="$(mktemp -d)"
  echo "Распаковываю ${ARCHIVE_PATH} в ${WORKDIR} ..."
  tar -xzf "${ARCHIVE_PATH}" -C "${WORKDIR}"

  # Если архив содержит вложенную папку с кодом — при необходимости подстроить
  # Предполагаем, что код в корне WORKDIR
  pushd "${WORKDIR}" >/dev/null

  if [[ ! -d .git ]]; then
    git init
    git config user.email "${ROOT_USERNAME}@${GITLAB_HOSTNAME}"
    git config user.name "GitLab Bootstrap"
    git add .
    git commit -m "Initial import" || true
  fi

  REPO_HTTP_URL="${GITLAB_URL}/${path_no_git}.git"
  REPO_PUSH_URL="${REPO_HTTP_URL/http:\/\//http://${ROOT_USERNAME}:${ROOT_TOKEN}@}"

  git remote remove origin 2>/dev/null || true
  git remote add origin "${REPO_PUSH_URL}"

  git push -u origin --all
  git push origin --tags || true

  # Дополнительные ветки (только если указаны)
  EXTRA_BRANCHES="${PROJECTS[$full]}"
  if [[ -n "$EXTRA_BRANCHES" ]]; then
      for branch in $EXTRA_BRANCHES; do
          git checkout -b "$branch" master  # Создать от master (локальной)
          git push -u origin "$branch"
          echo "Дополнительная ветка запушена: $branch"
      done
  fi

  popd >/dev/null
  rm -rf "${WORKDIR}"

  echo "Проект ${path_no_git}.git успешно залит"
done

echo
echo "=== Все проекты обработаны ==="
