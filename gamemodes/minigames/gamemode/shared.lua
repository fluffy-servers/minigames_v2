local gm = CreateConVar("mg_proxy_gamemode", "fluffy_suicidebarrels", {FCVAR_ARCHIVE, FCVAR_REPLICATED})
DeriveGamemode(gm:GetString())

function GM:GetGameDescription()
    return "Minigames"
end