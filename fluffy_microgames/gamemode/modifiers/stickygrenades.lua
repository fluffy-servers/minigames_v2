-- Sticky Grenades
-- Players are stuck and must throw grenades to eliminate opponents
MOD = {
    name = 'Sticky Grenades',
    subtext = 'Just to clarify: the grenades aren\'t sticky.',
    func_player = function(ply)
        ply:SetRunSpeed(1)
        ply:SetWalkSpeed(1)
        ply:SetJumpPower(1)
        ply:Give('weapon_frag')
        ply:GiveAmmo(100, 'Grenade')
    end
}