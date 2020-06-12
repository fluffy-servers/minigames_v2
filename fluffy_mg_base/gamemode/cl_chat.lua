local minigames_chat_commands = {}
minigames_chat_commands['!crosshair'] = "mg_crosshair_editor"
minigames_chat_commands['!help'] = "mg_info"
minigames_chat_commands['!team'] = "mg_team"

hook.Add("OnPlayerChat", "MinigamesChatCommands", function(ply, text, team, dead)
    if ply != LocalPlayer() then return end

    text = string.lower(text)
    if minigames_chat_commands[text] then
        LocalPlayer():ConCommand(minigames_chat_commands[text])
    end
end)