class_name Rock
extends Interactable

func is_valid_tool(tool: Tool) -> bool:
	return tool is PickaxeTool
