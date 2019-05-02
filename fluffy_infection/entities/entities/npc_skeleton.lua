AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Skeleton'

if CLIENT then
    language.Add('npc_skeleton', 'Skeleton' )
end

-- Speed
ENT.Speed = 160
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/skeleton.mdl"
ENT.BaseHealth = 200
ENT.Damage = 25
ENT.ModelScale = 1
ENT.Color = Color(0, 0, 255)