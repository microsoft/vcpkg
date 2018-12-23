include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds not supported yet.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIAGameWorks/PhysX
    REF 4.0.0
    SHA512 4e95caaa009ac972b740bb8647b8a42a343ff4137b047ea22c778234ddebf31631dc7176aae5430dc42311e0ef2d5321dcae2c71b8fdc0586927e599b6632eb8
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	set(WINDOWS_PLATFORM 32)
	set(MSBUILD_PLATFORM "Win32")
else ()
	set(WINDOWS_PLATFORM 64)
	set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif ()

vcpkg_execute_required_process( 
	COMMAND ${SOURCE_PATH}/physx/generate_projects.bat vc15win${WINDOWS_PLATFORM}
	WORKING_DIRECTORY ${SOURCE_PATH}/physx
	LOGNAME build-${TARGET_TRIPLET}
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/physx/compiler/vc15win${WINDOWS_PLATFORM}/sdk_source_bin/PhysX.sln
	RELEASE_CONFIGURATION release
	DEBUG_CONFIGURATION checked
    PLATFORM ${MSBUILD_PLATFORM}
)

file(INSTALL ${SOURCE_PATH}/physx/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/physx/)

file(GLOB RELEASE_BINS "${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc141.mt/release/*.dll")
foreach(ITR ${RELEASE_BINS})
	file(INSTALL ${ITR} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endforeach()

file(GLOB RELEASE_LIBS "${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc141.mt/release/*.lib")
foreach(ITR ${RELEASE_LIBS})
	file(INSTALL ${ITR} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endforeach()

file(GLOB DEBUG_BINS "${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc141.mt/checked/*.dll")
foreach(ITR ${DEBUG_BINS})
	file(INSTALL ${ITR} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endforeach()

file(GLOB DEBUG_LIBS "${SOURCE_PATH}/physx/bin/win.x86_${WINDOWS_PLATFORM}.vc141.mt/checked/*.lib")
foreach(ITR ${DEBUG_LIBS})
	file(INSTALL ${ITR} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endforeach()

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/physx RENAME copyright)
