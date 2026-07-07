class_name TreePlant
extends Interactable

func is_valid_tool(tool: Tool) -> bool:
	return tool is AxeTool
