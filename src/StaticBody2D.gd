extends StaticBody2D

# This code will generate the following error when the first CollisionPolygon2D is added:-
# E 0:00:04.820   decompose_polygon_in_convex: Convex decomposing failed!
#   <C++ Source>  core/math/geometry.cpp:675 @ decompose_polygon_in_convex()
#   <Stack Trace> StaticBody2D.gd:59 @ update_bitmap()
#                 StaticBody2D.gd:10 @ _ready()
# 
# Alsom if you turn on Visible Collision Shapes, you also get the error:
# E 0:00:00.614   canvas_item_add_polygon: Invalid polygon data, triangulation failed.
#   <C++ Error>   Condition "indices.empty()" is true.
#   <C++ Source>  servers/visual/visual_server_canvas.cpp:725 @ canvas_item_add_polygon()

var levelBM = BitMap.new()
var polygons = []
var collision_polygons = []

func _ready():
	levelBM.create_from_image_alpha($Sprite.texture.get_data(), 0.1)
	update_bitmap(false, true)
	$Sprite.visible = false
	pass
	
	
func update_bitmap(_debug: bool, hack: bool):
	for i in polygons:
		i.queue_free()
	for i in collision_polygons:
		i.queue_free()
		
	polygons = []
	collision_polygons = []

	var offset = $Sprite.position - Vector2($Sprite.texture.get_width()/2, $Sprite.texture.get_height()/2)
	var arr = levelBM.opaque_to_polygons(Rect2(-$Sprite.texture.get_data().get_width()/2, -$Sprite.texture.get_data().get_height()/2, $Sprite.texture.get_data().get_width()*2,$Sprite.texture.get_data().get_height()*2), 3)#5)

	for i in arr.size():
		var pva : PoolVector2Array = arr[i]

		# Check it has at least 4 points
#		if pva.size() <= 3:
#			continue
		
		# Check this point isn't the same as a previous point
#		var prev_pos : Vector2
#		var idx = 0
#		for pos in pva:
#			if prev_pos.is_equal_approx(pos):
#				pva.remove(idx)
#				idx -= 1
#			idx += 1
#			prev_pos = pos
#			pass
			
		var p : Polygon2D = Polygon2D.new()
		p.polygon = arr[i]
		p.texture = $Sprite.texture
		p.position += offset
		polygons.append(p)
		call_deferred("add_child", p)

		var cp : CollisionPolygon2D = CollisionPolygon2D.new()
		cp.polygon = arr[i]
		cp.position += offset
		collision_polygons.append(cp)

#		call_deferred("add_child", cp)
		add_child(cp) # Get error here in the first iteration of the loop
	pass
	

