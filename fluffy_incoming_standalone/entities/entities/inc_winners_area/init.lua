ENT.Base = "base_entity"
ENT.Type = "brush"

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()	
end

/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
	if IsValid( self ) && entity:IsPlayer() then
        entity:Spawn()
        entity:AddFrags(1)
        entity:EmitSound('friends/friend_join.wav')
        for k, v in pairs(player.GetAll()) do
            v:ChatPrint( (entity:Nick() or 'Somebody') .. ' reached the top!' )
        end
	end
end

/*---------------------------------------------------------
   Name: PassesTriggerFilters
   Desc: Return true if this object should trigger us
---------------------------------------------------------*/
function ENT:PassesTriggerFilters( entity )
	return true
end

/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
---------------------------------------------------------*/
function ENT:KeyValue( key, value )
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
end

/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function ENT:OnRemove()
end
