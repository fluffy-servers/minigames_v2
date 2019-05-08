AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Fast Zombie'

if CLIENT then
    language.Add('npc_zombie_fast', 'Fast Zombie' )
end

-- Speed
ENT.Speed = 300
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/zombie_fast.mdl"
ENT.BaseHealth = 60
ENT.Damage = 10