vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfig
    REF v5.87.0
    SHA512 b9ad658f75c0ea97e69f203b60e1755cbcc3eadf807b72a9fcd063d1d544bc916a3bee8308a69d45c2f00291376f6ef63565b93d90bc426b171c6ad734016c82
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kconfig_compiler_kf5.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/kconfig_compiler_kf5.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kconf_update.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/kconf_update.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kreadconfig5.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kwriteconfig5.exe)
    file (GLOB EXES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${EXES})
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kreadconfig5)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kwriteconfig5)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kreadconfig5)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kwriteconfig5)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Config)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(APPEND ${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf "Data = ../../data")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")	
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

