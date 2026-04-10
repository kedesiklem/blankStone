
local M = {}

--- Affiche un hint d'infusion avec son son associé.
--- @param hint_data table   { message = string }
--- @param x        number
--- @param y        number
function M.onHint(hint_data, x, y)
    GamePrint(hint_data.message)
    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", x, y)
end

--- Affiche le feedback d'un échec de validation.
--- La raison "purity" déclenche le message de corruption (GamePrintImportant),
--- tous les autres échecs utilisent le canal hint (GamePrint).
--- @param result table  { ok=false, reason=string, message=string }
function M.onValidationFail(result)
    if result.reason == "purity" then
        GamePrintImportant("$text_blankstone_corrupt", "$text_blankstone_lies_desc")
    else
        GamePrint(result.message)
    end
end

--- Affiche le message de succès d'un stone crafté (infusion).
--- @param message string  Stone.message (titre seul via GamePrintImportant)
function M.onStoneSuccess(message)
    GamePrintImportant(message)
end

--- Affiche le message de succès d'une recette Fuse ou Forge.
--- Ne fait rien si la recette n'a pas de champ `message`.
--- @param recipe table
function M.onRecipeSuccess(recipe)
    if recipe.message then
        GamePrintImportant(recipe.message.title, recipe.message.desc)
    end
end

return M
