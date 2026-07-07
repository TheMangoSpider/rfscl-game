class_name Fish
extends Interactable

func is_valid_tool(tool: Tool) -> bool:
	return tool is SpearTool
