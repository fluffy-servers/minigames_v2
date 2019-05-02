AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Gold Skeleton'

if CLIENT then
    language.Add('npc_skeleton_gold', 'Gold Skeleton' )
end

-- Speed
ENT.Speed = 240
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/skeleton.mdl"
ENT.BaseHealth = 200
ENT.Damage = 25
ENT.ModelScale = 1.25
ENT.Color = Color(255, 255, 0)

ENT.CollisionSide = 10