# Script controlling the GUI

extends Control

# GUI nodes
var node_menu
var node_help
var node_settings
var node_notification
var node_journal
var node_crosshair

# Timer for notifications
var notification_timer

func _ready():
	node_notification = get_node("CenterContainerMiddle/Notification")
	node_journal = get_node("Journal")
	node_menu = get_node("IngameMenu")
	node_help = get_node("HelpMenu")
	node_settings = get_node("Settings")
	node_crosshair = get_node("CenterContainerFull/Crosshair")
	set_process_input(true)
	set_process(true)

# Hides and shows crosshair based on mouse mode
func _process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and node_crosshair.is_visible():
		node_crosshair.hide()
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and node_crosshair.is_hidden():
		node_crosshair.show()

func _input(event):
	if (event.type == InputEvent.KEY):
		# Hides and shows journal on key press
		if Input.is_action_pressed("journal"):
			if node_journal.is_hidden():
				node_journal.show()
			else:
				node_journal.hide()
		
		# Hide ingame menu
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if Input.is_action_pressed("ingame_menu") and node_menu.is_visible():
				node_menu._hide()
				node_help._hide()
				node_settings._hide()
		else: # Open ingame menu
			if Input.is_action_pressed("ingame_menu") and node_menu.is_hidden():
				node_menu._show()

# Sets the text in journal
func set_journal_text(text):
	node_journal.get_node("Text").set_bbcode("[u]" + text + "[/u]")
	change_notification("Goal: " + text, 5, true)

# Changes notification
func change_notification(notification, time, override=false):
	if notification_timer == null: # init timer
		notification_timer = node_notification.get_node("Timer")
		notification_timer.connect("timeout",self,"notification_timeout")
		notification_timer.set_one_shot(true)
	if notification_timer.get_time_left() < 0.1 or override: # must wait for notification to run out of time, or override it
		node_notification.set_text(notification)
		notification_timer.set_wait_time(time)
		notification_timer.start()
		node_notification.show()

# Hides notification when it times out
func notification_timeout():
	node_notification.hide()


