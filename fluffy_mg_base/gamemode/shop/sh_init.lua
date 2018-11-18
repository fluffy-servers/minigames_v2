if SERVER then
    AddCSLuaFile('cl_init.lua')
    include('sv_init.lua')
else
    include('cl_init.lua')
end