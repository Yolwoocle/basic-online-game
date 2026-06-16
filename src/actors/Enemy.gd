class_name Enemy
extends Actor

@onready var hp_label: Label = $HPLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_component: LifeComponent = $LifeComponent


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	super(delta)
	
	hp_label.text = ""
	hp_label.text += "HP: %s/%s" % [life_component.life, life_component.max_life]
