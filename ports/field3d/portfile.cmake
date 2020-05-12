include(vcpkg_common_functions)

if (VCPKG_TARGET_IS_WINDOWS)
	message(FATAL_ERROR "Windows is currently not supported.")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imageworks/Field3D
    REF v1.7.2
    SHA512 e4ea51310105980f759dce48830db8ae3592ce32a02b246214d8aed9df7a7f5c500314f2daf92196b7a76d648f2909b18112df4c5c3c8949c0676d710dfbf1f2
    HEAD_REF master
    PATCHES
        fix-build_error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/field3d)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/field3d/COPYING ${CURRENT_PACKAGES_DIR}/share/field3d/copyright)
