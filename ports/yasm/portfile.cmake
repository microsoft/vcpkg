include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO yasm/yasm
	REF v1.3.0
	SHA512 f5053e2012e0d2ce88cc1cc06e3bdb501054aed5d1f78fae40bb3e676fe2eb9843d335a612d7614d99a2b9e49dca998d57f61b0b89fac8225afa4ae60ae848f1
	HEAD_REF master
	PATCHES
		fix-InstallPath.patch
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON_PATH ${PYTHON2} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/vsyasm.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/yasm.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/ytasm.exe
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/yasm/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vsyasm.exe ${CURRENT_PACKAGES_DIR}/tools/yasm/vsyasm.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/yasm.exe ${CURRENT_PACKAGES_DIR}/tools/yasm/yasm.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ytasm.exe ${CURRENT_PACKAGES_DIR}/tools/yasm/ytasm.exe)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/yasm)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# 	Handle copyright
file(COPY ${SOURCE_PATH}/COPYING ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/yasm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/yasm/COPYING ${CURRENT_PACKAGES_DIR}/share/yasm/copyright)