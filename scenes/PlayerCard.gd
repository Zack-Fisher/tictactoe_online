extends PanelContainer

var _player: Player = null

@onready var _name_text: RichTextLabel = %NameText

func _ready():
    if _player == null:
        print("Player is null on the PlayerCard, this should not happen, aborting...")
        queue_free()
        return
    
    _name_text.clear()
    _name_text.append_text(_player.name)
