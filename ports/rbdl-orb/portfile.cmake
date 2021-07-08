if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(RBDL_STATIC ON)
else()
    set(RBDL_STATIC OFF)
endif()

find_program(GIT git)

set(GIT_URL "https://github.com/orb-hd/rbdl-orb.git")
set(GIT_REV "f92b82b3c438c105555a1e50f3b880e716f1f90d")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)


if(NOT EXISTS "${SOURCE_PATH}/.git")
	message(STATUS "Cloning and fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone --recursive ${GIT_URL} ${SOURCE_PATH}
	  LOGNAME clone
	)
endif()		

message(STATUS "Pull latests commits")
vcpkg_execute_required_process(
  COMMAND ${GIT} pull origin master
  WORKING_DIRECTORY ${SOURCE_PATH}
  LOGNAME checkout
)	

message(STATUS "Checkout revision ${GIT_REV}")
vcpkg_execute_required_process(
  COMMAND ${GIT} checkout ${GIT_REV}
  WORKING_DIRECTORY ${SOURCE_PATH}
  LOGNAME checkout
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DRBDL_BUILD_STATIC=${RBDL_STATIC}
	-DRBDL_BUILD_ADDON_LUAMODEL=ON
	-DRBDL_BUILD_ADDON_GEOMETRY=ON
	-DRBDL_BUILD_ADDON_URDFREADER=ON
	-DRBDL_BUILD_EXECUTABLES=OFF
)

vcpkg_install_cmake()

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# # Remove duplicated include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
