add_library(unofficial::VulkanMemoryAllocator-Hpp::VulkanMemoryAllocator-Hpp INTERFACE IMPORTED)

set_target_properties(
	unofficial::VulkanMemoryAllocator-Hpp::VulkanMemoryAllocator-Hpp
	PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
)
