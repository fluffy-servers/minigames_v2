GM.DefaultProps = {}
GM.DefaultProps['Geometric'] = {
    models = {
        "models/clannv/incoming/box/box1.mdl",
        "models/clannv/incoming/box/box2.mdl",
        "models/clannv/incoming/box/box3.mdl",
        
        "models/clannv/incoming/cone/cone1.mdl",
        "models/clannv/incoming/cone/cone2.mdl",
        "models/clannv/incoming/cone/cone3.mdl",
        
        "models/clannv/incoming/cylinder/cylinder1.mdl",
        "models/clannv/incoming/cylinder/cylinder2.mdl",
        "models/clannv/incoming/cylinder/cylinder3.mdl",
        
        "models/clannv/incoming/hexagon/hexagon1.mdl",
        "models/clannv/incoming/hexagon/hexagon2.mdl",
        "models/clannv/incoming/hexagon/hexagon3.mdl",
        
        "models/clannv/incoming/pentagon/pentagon1.mdl",
        "models/clannv/incoming/pentagon/pentagon2.mdl",
        "models/clannv/incoming/pentagon/pentagon3.mdl",
        
        "models/clannv/incoming/sphere/sphere1.mdl",
        "models/clannv/incoming/sphere/sphere2.mdl",
        "models/clannv/incoming/sphere/sphere3.mdl",
        
        "models/clannv/incoming/triangle/triangle1.mdl",
        "models/clannv/incoming/triangle/triangle2.mdl",
        "models/clannv/incoming/triangle/triangle3.mdl"
    }
}

GM.DefaultProps['Vehicles'] = {
    models = {
        'models/props_vehicles/van001a_physics.mdl',
        'models/props_vehicles/car001a_hatchback.mdl',
        'models/props_vehicles/car001b_hatchback.mdl',
        'models/props_vehicles/car002a_physics.mdl',
        'models/props_vehicles/car002b_physics.mdl',
        'models/props_vehicles/car003a_physics.mdl',
        'models/props_vehicles/car003b_physics.mdl',
        'models/props_vehicles/car004a_physics.mdl',
        'models/props_vehicles/car004b_physics.mdl',
        'models/props_vehicles/car005a_physics.mdl',
        'models/props_vehicles/car005b_physics.mdl',
        'models/props_vehicles/apc001.mdl',
        'models/props_vehicles/trailer001a.mdl',
        'models/props_vehicles/trailer002a.mdl',
        'models/props_vehicles/truck001a.mdl',
        'models/props_vehicles/truck003a.mdl',
    }
}

GM.DefaultProps['Both'] = {
    models = {
        'models/props_vehicles/van001a_physics.mdl',
        'models/props_vehicles/car001a_hatchback.mdl',
        'models/props_vehicles/car001b_hatchback.mdl',
        'models/props_vehicles/car002a_physics.mdl',
        'models/props_vehicles/car002b_physics.mdl',
        'models/props_vehicles/car003a_physics.mdl',
        'models/props_vehicles/car003b_physics.mdl',
        'models/props_vehicles/car004a_physics.mdl',
        'models/props_vehicles/car004b_physics.mdl',
        'models/props_vehicles/car005a_physics.mdl',
        'models/props_vehicles/car005b_physics.mdl',
        'models/props_vehicles/apc001.mdl',
        'models/props_vehicles/trailer001a.mdl',
        'models/props_vehicles/trailer002a.mdl',
        'models/props_vehicles/truck001a.mdl',
        'models/props_vehicles/truck003a.mdl',
        
        "models/clannv/incoming/box/box1.mdl",
        "models/clannv/incoming/box/box2.mdl",
        "models/clannv/incoming/box/box3.mdl",
        
        "models/clannv/incoming/cone/cone1.mdl",
        "models/clannv/incoming/cone/cone2.mdl",
        "models/clannv/incoming/cone/cone3.mdl",
        
        "models/clannv/incoming/cylinder/cylinder1.mdl",
        "models/clannv/incoming/cylinder/cylinder2.mdl",
        "models/clannv/incoming/cylinder/cylinder3.mdl",
        
        "models/clannv/incoming/hexagon/hexagon1.mdl",
        "models/clannv/incoming/hexagon/hexagon2.mdl",
        "models/clannv/incoming/hexagon/hexagon3.mdl",
        
        "models/clannv/incoming/pentagon/pentagon1.mdl",
        "models/clannv/incoming/pentagon/pentagon2.mdl",
        "models/clannv/incoming/pentagon/pentagon3.mdl",
        
        "models/clannv/incoming/sphere/sphere1.mdl",
        "models/clannv/incoming/sphere/sphere2.mdl",
        "models/clannv/incoming/sphere/sphere3.mdl",
        
        "models/clannv/incoming/triangle/triangle1.mdl",
        "models/clannv/incoming/triangle/triangle2.mdl",
        "models/clannv/incoming/triangle/triangle3.mdl"
    }
}

GM.DefaultProps['CubesAndSpheres'] = {
    models = {
        'models/hunter/blocks/cube05x05x05.mdl',
        'models/hunter/blocks/cube075x075x075.mdl',
        'models/hunter/blocks/cube1x1x1.mdl',
        'models/hunter/blocks/cube1x150x1.mdl',
        'models/hunter/blocks/cube1x6x1.mdl',
        'models/hunter/blocks/cube2x2x2.mdl',
        'models/hunter/blocks/cube2x4x1.mdl',
        'models/hunter/blocks/cube2x6x1.mdl',
        'models/hunter/blocks/cube4x4x4.mdl',
        'models/hunter/misc/sphere175x175.mdl',
        'models/hunter/misc/sphere1x1.mdl',
        'models/hunter/misc/sphere2x2.mdl',
        'models/hunter/misc/sphere375x375.mdl'
    },
    
    func = function(e)
        local c = HSVToColor(math.random(360), 1, 1)
        e:SetColor(c)
    end
}

GM.MapInfo = {}
GM.MapInfo['inc_duo'] = {
    endpos = Vector( -1650, 5950, 6656 ),
    distance = 9000
}

GM.MapInfo['inc_rectangular'] = {
    endpos = Vector( 158, 1027, 3815 ),
    distance = 8420
}

GM.MapInfo['inc_linear'] = {
    endpos = Vector( 0, 4991, 3456 ),
    distance = 12500
}