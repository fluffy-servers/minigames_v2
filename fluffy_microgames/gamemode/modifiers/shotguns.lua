-- Example of a modifier using a different file structure
-- This is a perfectly OK way of creating the files
-- I just have the other files in the other way because I'm lazy
MOD.name = 'Shotguns'
MOD.subtext = 'pew pew pew'
MOD.func_player = function(ply)
    ply:Give('weapon_shotgun')
    ply:GiveAmmo(80, 'Buckshot')
end