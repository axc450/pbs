local L = LibStub('AceLocale-3.0'):NewLocale('PetBattleScripts', 'itIT')
if not L then return end

--[[ L["ADDON_NAME"] = "Pet Battle Scripts" --]]
L["DATABASE_UPDATE_BASE_TO_FIRSTENEMY_NOTIFICATION"] = "Si è riscontrato che hai già utilizzato la versione modificata di tdBattlePetScript e alcuni script della versione modificata del selettore Base sono stati migrati al selettore FirstEnemy."
L["DATABASE_UPDATED_TO"] = "Aggiorna alla versione:"
L["DEFAULT_NEW_SCRIPT_NAME"] = "Nuovo Script"
--[[ L["DIRECTOR_TEST_NEXT_ACTION"] = "Next action" --]]
L["EDITOR_CREATE_SCRIPT"] = "Crea script"
L["EDITOR_EDIT_SCRIPT"] = "Modifica lo script"
L["IN_BATTLE_DEBUGGING_SCRIPT"] = "Script di Debug"
--[[ L["IN_BATTLE_EXECUTE"] = "Autobattle" --]]
L["IN_BATTLE_NO_SCRIPT"] = "Nessuno Script"
L["IN_BATTLE_SELECT_SCRIPT"] = "Seleziona script"
L["OPTION_AUTO_SELECT_SCRIPT_BY_ORDER"] = "Seleziona automaticamente gli script in base alla priorità del selettore di script"
L["OPTION_AUTO_SELECT_SCRIPT_ONLY_ONE"] = "Seleziona automaticamente quando è presente un solo script"
L["OPTION_AUTOBUTTON_HOTKEY"] = "Tasti di scelta rapida automatici"
--[[ L["OPTION_AUTOBUTTON_HOTKEY_SECONDARY"] = "(secondary)" --]]
L["OPTION_EDITOR_FONT_FACE"] = "Font"
L["OPTION_EDITOR_FONT_SIZE"] = "Dimensione Font"
L["OPTION_HIDE_MINIMAP"] = "Nascondi l'icona della minimappa"
L["OPTION_HIDE_SELECTOR_NO_SCRIPT"] = "Non mostrare il selettore di script quando non c'è uno script"
L["OPTION_LOCK_SCRIPT_SELECTOR"] = "Blocca il selettore di script"
L["OPTION_NO_WAIT_DELETE_SCRIPT"] = "Non aspettare quando elimini gli script"
--[[ L["OPTION_NOTIFY_BUTTON_ACTIVE"] = "Play sound when \"Autobattle\" button becomes active" --]]
--[[ L["OPTION_NOTIFY_BUTTON_ACTIVE_SOUND"] = "Sound" --]]
L["OPTION_RESET_FRAMES"] = "Ripristina le dimensioni e la posizione del pannello"
L["OPTION_SCRIPTSELECTOR_NOTES"] = "Qui puoi gestire se il selettore di script è abilitato e la priorità del selettore di script."
L["OPTION_SETTINGS_HIDE_MINIMAP_TOOLTIP"] = "La modifica di questa impostazione richiede il ricaricamento dell'interfaccia utente. Continuare?"
L["OPTION_TEST_BREAK"] = "Debug: il comando test interrompe lo script"
--[[ L["REMATCH_NOTE_SCRIPT_EXPORT_ADD_TO_NOTE_MENU_ITEM"] = "Add script to note" --]]
--[[ L["REMATCH_NOTE_SCRIPT_IMPORT_FAIL"] = [=[Importing at least one script from Rematch team notes failed:
%s]=] --]]
--[[ L["REMATCH_NOTE_SCRIPT_IMPORT_FAIL_EXIST_DIFFERENT"] = "A script already exists, and it is a different one. Delete note or script." --]]
--[[ L["REMATCH_NOTE_SCRIPT_IMPORT_FAIL_LINE"] = "- Team \"%s\": %s" --]]
--[[ L["REMATCH4_DEPRECATED"] = [=[Rematch 4 is old and support of the pet battle scripts addon for it will be dropped mid 2025. Please upgrade to Rematch 5.

Also, please notify us on Curseforge or GitHub, as we want to count whether a relevant number of users still use Rematch 4, contrary to our assumptions.]=] --]]
L["SCRIPT_EDITOR_AUTOFORMAT_SCRIPT"] = "Script di Abbellimento"
L["SCRIPT_EDITOR_DELETE_SCRIPT_CONFIRMATION"] = "Sei sicuro di voler |cffff0000cancella|r script |cffffd000[%s - %s]|r?"
L["SCRIPT_EDITOR_FOUND_ERROR"] = "Trovato Errore"
L["SCRIPT_EDITOR_LABEL_TOGGLE_EXTRA"] = "Attiva/disattiva editor di informazioni sull'estensione"
L["SCRIPT_EDITOR_NAME_TITLE"] = "Nome dello Script"
L["SCRIPT_EDITOR_RUN_BUTTON"] = "Avvia"
L["SCRIPT_EDITOR_SAVE_SUCCESS"] = "Salvato con successo"
L["SCRIPT_EDITOR_TEXTAREA_TITLE"] = "Script"
L["SCRIPT_EDITOR_TITLE"] = "Editore di script"
L["SCRIPT_MANAGER_TITLE"] = "Gestore di Script"
L["SCRIPT_MANAGER_TOGGLE"] = "Attiva/disattiva gestione degli script"
L["SCRIPT_SELECTOR_TITLE"] = "Selettore di script"
L["SCRIPT_SELECTOR_TOGGLE"] = "Attiva/disattiva il selettore di script"
L["SELECTOR_ALLINONE_NOTES"] = "Tutte le battaglie pokemon possono usare questo script."
L["SELECTOR_ALLINONE_TITLE"] = "Tutto in uno"
L["SELECTOR_BASE_ALLY"] = "La nostra formazione"
L["SELECTOR_BASE_ENEMY"] = "La formazione nemica"
L["SELECTOR_BASE_NOTES"] = "Questo selettore di script lega lo script alla formazione completa delle squadre avversarie."
L["SELECTOR_BASE_TITLE"] = "Base"
L["SELECTOR_FIRSTENEMY_NOTES"] = "Questo selettore di script lega lo script al primo nemico della battaglia."
L["SELECTOR_FIRSTENEMY_TITLE"] = "Primo nemico"
--[[ L["SELECTOR_REMATCH_4_TO_5_UPDATE_NOTE"] = [=[Updated from Rematch 4 to Rematch 5. Please check whether your scripts are still correctly linked to teams.

If the upgrade failed, restore a backup of wow/WTF/Account/<account>/SavedVariables/tdBattlePetScript.lua, or open it and search for "Rematch" and remove or replace with "Rematch5", then search for "Rematch4" and replace it with "Rematch". Then downgrade back to Rematch 4 and report a bug on https://github.com/axc450/pbs/issues/new, attaching your saved variables file for Rematch and this addon.]=] --]]
--[[ L["SELECTOR_REMATCH_4_TO_5_UPDATE_ORPHAN"] = [=[Found script named "%s" which is linked to the non-existent Rematch team id "%s".

This can indicate an issue during updating the database, or a previous corruption. If this error has happened to a lot of teams, please report it as a bug. Otherwise, just remove orphaned teams via the Script Manager and re-add them to the correct teams.]=] --]]
--[[ L["SELECTOR_REMATCH_CANT_FORMAT_TOOLTIP_REMATCH_NOT_LOADED"] = "Can't show information: Rematch addon not loaded." --]]
--[[ L["SELECTOR_REMATCH_NO_TEAM_FOR_SCRIPT"] = "No team matches this script" --]]
--[[ L["SELECTOR_REMATCH_NOTES"] = "This script selector will be bound to the Rematch team." --]]
--[[ L["SELECTOR_REMATCH_TEAM_FORMAT"] = "Team: %s" --]]
--[[ L["SELECTOR_REMATCH_TITLE"] = "Rematch" --]]
L["SHARE_EXPORT_SCRIPT"] = "Esporta"
L["SHARE_IMPORT_CHOOSE_KEY"] = "Seleziona un valore per chiudere..."
L["SHARE_IMPORT_CHOOSE_SELECTOR"] = "Seleziona un selettore di script..."
L["SHARE_IMPORT_LABEL_ALREADY_EXISTS_CHECKBOX"] = "Sovrascrivi e continua a importare"
L["SHARE_IMPORT_LABEL_ALREADY_EXISTS_WARNING"] = "Uno script esiste già in questa modalità di corrispondenza, continuare a importare sovrascriverà lo script corrente."
--[[ L["SHARE_IMPORT_LABEL_HAS_EXTRA"] = "This import string will import extra data in addition to just the script, depending on the script plugin. Usually, this is information about the corresponding team." --]]
--[[ L["SHARE_IMPORT_PLUGIN_NOT_ENABLED"] = "Can't import: Plugin is not enabled." --]]
L["SHARE_IMPORT_REINPUT_TEXT"] = "Ri-Modificare"
L["SHARE_IMPORT_SCRIPT"] = "Importare"
L["SHARE_IMPORT_SCRIPT_EXISTS"] = "lo script esiste già"
L["SHARE_IMPORT_SCRIPT_NOT_IMPORT_STRING_WARNING"] = "Hai inserito lo script, ti consigliamo di utilizzare il codice di condivisione per importare, ovviamente puoi continuare a importare."
L["SHARE_IMPORT_SCRIPT_WELCOME"] = "Copia la stringa o lo script di condivisione nella casella di input."
L["SHARE_IMPORT_STRING_INCOMPLETE"] = "I dati della stringa condivisa sono incompleti. Ma può ancora essere importato."
L["TOOLTIP_CREATE_OR_DEBUG_SCRIPT"] = "Crea o esegui il debug di script"
