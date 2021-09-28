if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
     list(APPEND PATCHES fix_static_builds.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ki18n
    REF v5.84.0
    SHA512 611481b0d5f387b6e1201c1d38e050bd6c956607d059679c68f39d8560cdde666709f5aa1ae770e200fb81e902da85160eb3eeaf5c0bdb02c0ff13782df1d907
    PATCHES ${PATCHES}
)

vcpkg_find_acquire_program(PYTHON3)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5I18n)
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
