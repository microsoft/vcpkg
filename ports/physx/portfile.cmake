include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds not supported yet.")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
	set(WINDOWS_PLATFORM "32")
	set(MSBUILD_PLATFORM "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
	set(WINDOWS_PLATFORM "64")
	set(MSBUILD_PLATFORM "x64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if (VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
	set(VCPKG_PLATFORM_TOOLSET "v141")
endif()

if (VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
	set(MSVC_VERSION "14")
	set(TOOLSET_VERSION "140")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
	set(MSVC_VERSION "15")
	set(TOOLSET_VERSION "141")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
	set(MSVC_VERSION "16")
	set(TOOLSET_VERSION "142")
else()
    message(FATAL_ERROR "Unsupported platform toolset.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIAGameWorks/PhysX
    REF 624f2cb6c0392013d54b235d9072a49d01c3cb6c
    SHA512 80b465f6214434fd53954fe124d8f8aa1ddfcb60d80261f1dc06713bf7fb0f42d8cd96a393fbc46547d9c2199039f386220d7eea63c849ad98863ff26b731e0c
    HEAD_REF master
)

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic") 
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES ${CMAKE_CURRENT_LIST_DIR}/use_dynamic_wincrt.patch
	)
elseif (VCPKG_CRT_LINKAGE STREQUAL "static")
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES ${CMAKE_CURRENT_LIST_DIR}/use_static_wincrt.patch
	)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

vcpkg_execute_required_process( 
	COMMAND ${SOURCE_PATH}/physx/generate_projects.bat vc${MSVC_VERSION}win${WINDOWS_PLATFORM}
	WORKING_DIRECTORY ${SOURCE_PATH}/physx
	LOGNAME build-${TARGET_TRIPLET}
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/physx/compiler/vc15win${WINDOWS_PLATFORM}/sdk_source_bin/PhysX.sln
	RELEASE_CONFIGURATION release
	DEBUG_CONFIGURATION debug
    PLATFORM ${MSBUILD_PLATFORM}
)

file(INSTALL ${SOURCE_PATH}/physx/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/physx/)

file(GLOB RELEASE_BINS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.md/release/*.dll)
file(INSTALL ${RELEASE_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(GLOB RELEASE_LIBS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.md/release/*.lib)
file(INSTALL ${RELEASE_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(GLOB DEBUG_BINS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.md/debug/*.dll)
file(INSTALL ${DEBUG_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(GLOB DEBUG_LIBS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.md/debug/*.lib)
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/physx RENAME copyright)
