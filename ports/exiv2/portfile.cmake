include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF db5bb66d0697572eacaf0c2aa3b8e7ac2a0c4e54
    SHA512 afc82f79073ace4d567a9db4ee8991c013d12b2939930e12fe5adf0f7d398b87bce127689f3ca9b1c234cc1321ed3f6bee8335590958616a03af9de58e12c24b
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH "${SOURCE_PATH}"
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/use-iconv.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "share/exiv2/cmake")

vcpkg_copy_pdbs()

# Clean
file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${EXE} ${DEBUG_EXE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright 
file(COPY ${SOURCE_PATH}/ABOUT-NLS DESTINATION ${CURRENT_PACKAGES_DIR}/share/exiv2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/exiv2/ABOUT-NLS ${CURRENT_PACKAGES_DIR}/share/exiv2/copyright)
