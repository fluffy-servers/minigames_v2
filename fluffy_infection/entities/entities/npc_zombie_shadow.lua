AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Shadow'

if CLIENT then
    language.Add('npc_zombie_shadow', 'Shadow' )
end

-- Speed
ENT.Speed = 240
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/charple.mdl"
ENT.BaseHealth = 200
ENT.Damage = 40