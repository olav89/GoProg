extends Control

var node_menu
var node_help
var node_settings
var node_notification
var node_journal
var node_crosshair

var notification_timer

func _ready():
	node_notification = get_node("CenterContainerTop/Notification")
	node_journal = get_node("Journal")
	node_menu = get_node("IngameMenu")
	node_help = get_node("HelpMenu")
	node_settings = get_node("Settings")
	node_crosshair = get_node("CenterContainerFull/Crosshair")
	set_process_input(true)
	set_process(true)

func _process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and node_crosshair.is_visible():
		node_crosshair.hide()
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and node_crosshair.is_hidden():
		node_crosshair.show()

func _input(event):
	if (event.type == InputEvent.KEY):
		if Input.is_action_pressed("journal"):
			if node_journal.is_hidden():
				node_journal.show()
			else:
				node_journal.hide()
				
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if Input.is_action_pressed("ingame_menu") and node_menu.is_visible():
				node_menu._hide()
				node_help._hide()
				node_settings._hide()
			# HIDE TUTORIAL LEVEL
		else:
			# Open menu
			if Input.is_action_pressed("ingame_menu") and node_menu.is_hidden():
				node_menu._show()

func set_journal_text(text):
	node_journal.get_node("Text").set_bbcode("[u]" + text + "[/u]")

func change_notification(notification, time):
	node_notification.get_node("Label").set_text(notification)
	if notification_timer == null:
		notification_timer = node_notification.get_node("Timer")
		notification_timer.connect("timeout",self,"notification_timeout")
		notification_timer.set_one_shot(true)
	notification_timer.set_wait_time(time)
	notification_timer.start()
	node_notification.show()

func notification_timeout():
	node_notification.hide()


