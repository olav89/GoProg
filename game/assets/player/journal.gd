extends TextureFrame

func change_journal(journal_text):
	get_node("Task").set_bbcode("[u]" + journal_text + "[/u]")