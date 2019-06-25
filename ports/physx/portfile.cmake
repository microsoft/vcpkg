include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Error: UWP builds not supported.")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
	set(WINDOWS_PLATFORM "32")
	set(MSBUILD_PLATFORM "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
	set(WINDOWS_PLATFORM "64")
	set(MSBUILD_PLATFORM "x64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if (VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
	set(MSVC_VERSION "14")
	set(TOOLSET_VERSION "140")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
	set(MSVC_VERSION "15")
	set(TOOLSET_VERSION "141")
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

set(BUILD_SNIPPETS "False")
set(BUILD_PUBLIC_SAMPLES "False")
set(FLOAT_POINT_PRECISE_MATH "False")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	set(GENERATE_STATIC_LIBRARIES "True")
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(GENERATE_STATIC_LIBRARIES "False")
endif()

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
	set(USE_STATIC_WINCRT "False")
	set(RUNTIME_LIBRARY_LINKAGE "md")
elseif (VCPKG_CRT_LINKAGE STREQUAL "static")
	set(USE_STATIC_WINCRT "True")
	set(RUNTIME_LIBRARY_LINKAGE "mt")
endif()

set(PRESET_FILE vc${MSVC_VERSION}win${WINDOWS_PLATFORM}-${RUNTIME_LIBRARY_LINKAGE}-${VCPKG_LIBRARY_LINKAGE})
file(REMOVE ${SOURCE_PATH}/physx/buildtools/presets/public/${PRESET_FILE}.xml)
configure_file(${CMAKE_CURRENT_LIST_DIR}/preset.xml.in ${SOURCE_PATH}/physx/buildtools/presets/public/${PRESET_FILE}.xml)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

get_filename_component(CMAKE_DIR ${CMAKE_COMMAND} DIRECTORY)
# If cmake is not installed then adding it to the end of the path
# will allow generate_projects.bat to find the cmake used by vcpkg.
vcpkg_add_to_path(${CMAKE_DIR})

vcpkg_execute_required_process( 
	COMMAND ${SOURCE_PATH}/physx/generate_projects.bat ${PRESET_FILE}
	WORKING_DIRECTORY ${SOURCE_PATH}/physx
	LOGNAME build-${TARGET_TRIPLET}
)

set(RELEASE_CONFIGURATION "release")
set(DEBUG_CONFIGURATION "debug")

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/physx/compiler/vc15win${WINDOWS_PLATFORM}/PhysXSDK.sln
	RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
	DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
    PLATFORM ${MSBUILD_PLATFORM}
)

file(INSTALL ${SOURCE_PATH}/physx/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/physx/)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(GLOB RELEASE_BINS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.${RUNTIME_LIBRARY_LINKAGE}/${RELEASE_CONFIGURATION}/*.dll)
	file(INSTALL ${RELEASE_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

	file(GLOB DEBUG_BINS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.${RUNTIME_LIBRARY_LINKAGE}/${DEBUG_CONFIGURATION}/*.dll)
	file(INSTALL ${DEBUG_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(GLOB RELEASE_LIBS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.${RUNTIME_LIBRARY_LINKAGE}/${RELEASE_CONFIGURATION}/*.lib)
file(INSTALL ${RELEASE_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(GLOB DEBUG_LIBS ${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc${TOOLSET_VERSION}.${RUNTIME_LIBRARY_LINKAGE}/${DEBUG_CONFIGURATION}/*.lib)
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/physx RENAME copyright)
