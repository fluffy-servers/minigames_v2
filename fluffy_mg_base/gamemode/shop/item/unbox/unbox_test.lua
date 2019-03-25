UNBOX = {}
UNBOX.VanillaID = 'unbox_test'
UNBOX.Items = {
	{ id='roadsign2'},
	{ id='roadsign7' },
	{ id='tracer_rainbow' },
}

UNBOX.Name='Test Box'
UNBOX.Type='Crate'
UNBOX.Model='models/props_junk/wood_crate001a.mdl'

UNBOX.Chances = {
    3,
    2,
    1,
}
SHOP:RegisterUnbox( UNBOX )