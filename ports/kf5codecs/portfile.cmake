vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcodecs
    REF v5.84.0
    SHA512 77f27883f588e9f4bd5458e4e4a596c494ff4fc0a7230ac757926db13d69f010a72f84d828ae83f48e5019ea96da58251c190dd6d38408f64089ac42501b7439
    HEAD_REF master
)

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_EXE_PATH ${GPERF} DIRECTORY)
vcpkg_add_to_path(${GPERF_EXE_PATH})

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Codecs CONFIG_PATH lib/cmake/KF5Codecs)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)