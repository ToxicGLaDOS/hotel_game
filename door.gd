extends RoomLink
class_name Door

func interact(player: Player):
    player.move_rooms(transition_point.global_position, camera_point.global_position)
