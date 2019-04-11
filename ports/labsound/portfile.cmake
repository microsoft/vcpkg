# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

find_program(GIT git)

set(GIT_URL "https://github.com/LabSound/LabSound.git")
set(GIT_REV "1567ec802d1525569ad3a46c97ef054679714fa7")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LabSound)


if(NOT EXISTS "${SOURCE_PATH}/.git")
	message(STATUS "Cloning and fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone --recurse-submodules ${GIT_URL} ${SOURCE_PATH}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME clone
	)

	message(STATUS "Checkout revision ${GIT_REV}")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} checkout ${GIT_REV}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME checkout
	)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
		-DBUILD_EXAMPLE=OFF
)

vcpkg_install_cmake()

# example delete https://github.com/SethMMorton/NPSpec/blob/master/distclean.cmake
FILE(GLOB_RECURSE DELETE_FILES_WAV ${CURRENT_PACKAGES_DIR}/libwavpack*)
FILE(GLOB_RECURSE DELETE_FILES_OPU ${CURRENT_PACKAGES_DIR}/libopus*)
FILE(GLOB_RECURSE DELETE_FILES_NYQ ${CURRENT_PACKAGES_DIR}/libnyquist*)

file(REMOVE_RECURSE 
	${DELETE_FILES_OPU} 
	${DELETE_FILES_WAV} 
	${DELETE_FILES_NYQ}
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/share
	${CURRENT_PACKAGES_DIR}/debug/bin
	${CURRENT_PACKAGES_DIR}/bin
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/labsound RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/labsound RENAME license)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/labsound RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME labsound)
