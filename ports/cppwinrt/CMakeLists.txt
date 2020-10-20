cmake_minimum_required(VERSION 3.15)
project(cppwinrt VERSION ${VERSION} LANGUAGES)

if ("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86")
	set(VCPKG_TARGET_ARCHITECTURE win32)
endif()

add_library(cppwinrt INTERFACE)
target_include_directories(cppwinrt
	INTERFACE
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		$<INSTALL_INTERFACE:include>
)
target_link_libraries(cppwinrt
	INTERFACE
		windowsapp.lib
		cppwinrt_fast_forwarder.lib
)
target_link_directories(cppwinrt
	INTERFACE
		$<INSTALL_INTERFACE:lib>
)
	
install(TARGETS cppwinrt EXPORT cppwinrt)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/winrt TYPE INCLUDE CONFIGURATIONS Release)
install(FILES build/native/lib/${VCPKG_TARGET_ARCHITECTURE}/cppwinrt_fast_forwarder.lib TYPE LIB)
install(EXPORT cppwinrt DESTINATION share/cppwinrt NAMESPACE cppwinrt:: FILE cppwinrtConfig.cmake)
