AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Corpse Walker'

if CLIENT then
    language.Add('npc_zombie_corpse', 'Corpse Walker' )
end

-- Speed
ENT.Speed = 150
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/corpse1.mdl"
ENT.BaseHealth = 150
ENT.Damage = 25