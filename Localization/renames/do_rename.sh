#!/bin/bash

set -euo pipefail

file="${1}"

function handle_line()
{
  local key="$(sed -e 's,^L\[\"\([^"]*\)\"\] = \".*\"$,\1,' <<<"${1}")"
  local value="$(sed -e 's,^L\[\"[^"]*\"\] = \"\(.*\)\"$,\1,' <<<"${1}")"
  local keep=false
  local delete=false
  local new_key=
  local new_value=

  case "${key}" in
    "ADDON_NAME") keep=true ;;
    "OPTION_SCRIPTSELECTOR_NOTES") keep=true ;;
    "OPTION_SETTINGS_HIDE_MINIMAP_TOOLTIP") keep=true ;;
    "SCRIPT_EDITOR_LABEL_TOGGLE_EXTRA") keep=true ;;
    "TOOLTIP_CREATE_OR_DEBUG_SCRIPT") keep=true ;;

    "WRITE_SCRIPT") delete=true ;;
    "DIALOG_COPY_URL_HELP") delete=true ;;
    "Don't ask me") delete=true ;;
    "Download") delete=true ;;
    "Installed") delete=true ;;
    "Not Installed") delete=true ;;
    "OPTION_GENERAL_NOTES") delete=true ;;
    "OPTION_SCRIPTEDITOR_NOTES") delete=true ;;
    "Options") delete=true ;;
    "PLUGINBASE_TOOLTIP_CREATE_SCRIPT") delete=true ;;
    "Script author") delete=true ;;
    "Script notes") delete=true ;;
    "SCRIPT_SELECTOR_LOST_TOOLTIP") delete=true ;;
    "SCRIPT_SELECTOR_NOT_MATCH") delete=true ;;
    "SCRIPT_SELECTOR_NOTINSTALLED_HELP") delete=true ;;
    "SCRIPT_SELECTOR_NOTINSTALLED_TEXT") delete=true ;;
    "TOOLTIP_CREATE_OR_DEBUG_SCRIPT") delete=true ;;

    "PLUGINFIRSTENEMY_NOTIFY") new_key='DATABASE_UPDATE_BASE_TO_FIRSTENEMY_NOTIFICATION' ;;
    "UPDATED") new_key='DATABASE_UPDATED_TO' ;;
    "New script") new_key='DEFAULT_NEW_SCRIPT_NAME' ;;
    "NEXT_ACTION") new_key='DIRECTOR_TEST_NEXT_ACTION' ;;
    "Create script") new_key='EDITOR_CREATE_SCRIPT' ;;
    "Edit script") new_key='EDITOR_EDIT_SCRIPT' ;;
    "Debugging script") new_key='IN_BATTLE_DEBUGGING_SCRIPT' ;;
    "Auto") new_key='IN_BATTLE_EXECUTE' ;;
    "No script") new_key='IN_BATTLE_NO_SCRIPT' ;;
    "Select script") new_key='IN_BATTLE_SELECT_SCRIPT' ;;
    "OPTION_SETTINGS_AUTO_SELECT_SCRIPT_BY_ORDER") new_key='OPTION_AUTO_SELECT_SCRIPT_BY_ORDER' ;;
    "OPTION_SETTINGS_AUTO_SELECT_SCRIPT_ONLY_ONE") new_key='OPTION_AUTO_SELECT_SCRIPT_ONLY_ONE' ;;
    "OPTION_SETTINGS_AUTOBUTTON_HOTKEY") new_key='OPTION_AUTOBUTTON_HOTKEY' ;;
    "Font face") new_key='OPTION_EDITOR_FONT_FACE' ;;
    "Font size") new_key='OPTION_EDITOR_FONT_SIZE' ;;
    "OPTION_SETTINGS_HIDE_MINIMAP") new_key='OPTION_HIDE_MINIMAP' ;;
    "OPTION_SETTINGS_HIDE_SELECTOR_NO_SCRIPT") new_key='OPTION_HIDE_SELECTOR_NO_SCRIPT' ;;
    "OPTION_SETTINGS_LOCK_SCRIPT_SELECTOR") new_key='OPTION_LOCK_SCRIPT_SELECTOR' ;;
    "OPTION_SETTINGS_NO_WAIT_DELETE_SCRIPT") new_key='OPTION_NO_WAIT_DELETE_SCRIPT' ;;
    "OPTION_SETTINGS_NOTIFY_BUTTON_ACTIVE") new_key='OPTION_NOTIFY_BUTTON_ACTIVE' ;;
    "OPTION_SETTINGS_NOTIFY_BUTTON_ACTIVE_SOUND") new_key='OPTION_NOTIFY_BUTTON_ACTIVE_SOUND' ;;
    "OPTION_SETTINGS_RESET_FRAMES") new_key='OPTION_RESET_FRAMES' ;;
    "OPTION_SETTINGS_TEST_BREAK") new_key='OPTION_TEST_BREAK' ;;
    "Beauty script") new_key='SCRIPT_EDITOR_AUTOFORMAT_SCRIPT' ;;
    "SCRIPT_EDITOR_DELETE_SCRIPT") new_key='SCRIPT_EDITOR_DELETE_SCRIPT_CONFIRMATION' ;;
    "Found error") new_key='SCRIPT_EDITOR_FOUND_ERROR' ;;
    "Script name") new_key='SCRIPT_EDITOR_NAME_TITLE' ;;
    "Run") new_key='SCRIPT_EDITOR_RUN_BUTTON' ;;
    "Save success") new_key='SCRIPT_EDITOR_SAVE_SUCCESS' ;;
    "Script") new_key='SCRIPT_EDITOR_TEXTAREA_TITLE' ;;
    "Script editor") new_key='SCRIPT_EDITOR_TITLE' ;;
    "Script manager") new_key='SCRIPT_MANAGER_TITLE' ;;
    "TOGGLE_SCRIPT_MANAGER") new_key='SCRIPT_MANAGER_TOGGLE' ;;
    "Script selector") new_key='SCRIPT_SELECTOR_TITLE' ;;
    "TOGGLE_SCRIPT_SELECTOR") new_key='SCRIPT_SELECTOR_TOGGLE' ;;
    "PLUGINALLINONE_NOTES") new_key='SELECTOR_ALLINONE_NOTES' ;;
    "PLUGINALLINONE_TITLE") new_key='SELECTOR_ALLINONE_TITLE' ;;
    "PLUGINBASE_TEAM_ALLY") new_key='SELECTOR_BASE_ALLY' ;;
    "PLUGINBASE_TEAM_ENEMY") new_key='SELECTOR_BASE_ENEMY' ;;
    "PLUGINBASE_NOTES") new_key='SELECTOR_BASE_NOTES' ;;
    "PLUGINBASE_TITLE") new_key='SELECTOR_BASE_TITLE' ;;
    "PLUGINFIRSTENEMY_NOTES") new_key='SELECTOR_FIRSTENEMY_NOTES' ;;
    "PLUGINFIRSTENEMY_TITLE") new_key='SELECTOR_FIRSTENEMY_TITLE' ;;
    "NO_TEAM_FOR_SCRIPT") new_key='SELECTOR_REMATCH_NO_TEAM_FOR_SCRIPT' ;;
    "NOTES") new_key='SELECTOR_REMATCH_NOTES' ;;
    "TITLE") new_key='SELECTOR_REMATCH_TITLE' ;;
    "Export") new_key='SHARE_EXPORT_SCRIPT' ;;
    "IMPORT_CHOOSE_KEY") new_key='SHARE_IMPORT_CHOOSE_KEY' ;;
    "IMPORT_CHOOSE_PLUGIN") new_key='SHARE_IMPORT_CHOOSE_SELECTOR' ;;
    "SCRIPT_IMPORT_LABEL_GOON") new_key='SHARE_IMPORT_LABEL_ALREADY_EXISTS_CHECKBOX' ;;
    "SCRIPT_IMPORT_LABEL_COVER") new_key='SHARE_IMPORT_LABEL_ALREADY_EXISTS_WARNING' ;;
    "SCRIPT_IMPORT_LABEL_EXTRA") new_key='SHARE_IMPORT_LABEL_EXTRA' ;;
    "IMPORT_REINPUT_TEXT") new_key='SHARE_IMPORT_REINPUT_TEXT' ;;
    "Import") new_key='SHARE_IMPORT_SCRIPT' ;;
    "IMPORT_SCRIPT_EXISTS") new_key='SHARE_IMPORT_SCRIPT_EXISTS' ;;
    "IMPORT_SCRIPT_WARNING") new_key='SHARE_IMPORT_SCRIPT_NOT_IMPORT_STRING_WARNING' ;;
    "IMPORT_SCRIPT_WELCOME") new_key='SHARE_IMPORT_SCRIPT_WELCOME' ;;
    "IMPORT_SHARED_STRING_WARNING") new_key='SHARE_IMPORT_STRING_INCOMPLETE' ;;

    "TEAM")
      new_key='SELECTOR_REMATCH_TEAM_FORMAT'
      new_value="${value} %s"
      ;;

    *)
      echo >&2 "Unknown key '${key}'"
      exit 1
  esac

  if "${delete}"
  then
    echo "-- DELETE: ${key} = ${value}"
  elif "${keep}"
  then
    echo "L[\"${key}\"] = \"${value}\""
  else
    echo "L[\"${new_key}\"] = \"${new_value:-${value}}\" -- WAS: ${key}"
  fi
}

function handle_file()
{
  local file="${1}"
  echo 'L = L or {}'
  while read -r line
  do
    handle_line "${line}"
  done < <(grep -v 'L = L or {}' "${file}")
}

for file in "${@}"
do
  handle_file "${file}" | sponge "${file}"
done


