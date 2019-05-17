AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Mini Skeleton'

if CLIENT then
    language.Add('npc_skeleton_mini', 'Mini Skeleton' )
end

-- Speed
ENT.Speed = 300
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/skeleton.mdl"
ENT.BaseHealth = 10
ENT.Damage = 15
ENT.ModelScale = 0.75
ENT.BoldColor = Color(255, 159, 243)

ENT.CollisionSide = 4