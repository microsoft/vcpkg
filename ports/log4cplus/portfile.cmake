include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_1_2_1-RC2
    SHA512  480a2a61b01e988253c1bf2bb26088030541a63811c8ffbb9e90581d556b717df5220e3ff72eedd27ea704af35218f71f20ceadf4d6d94984b4f56d273b4d3a3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DLOG4CPLUS_BUILD_TESTING=OFF -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF -DWITH_UNIT_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/log4cplus)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/log4cplus/LICENSE ${CURRENT_PACKAGES_DIR}/share/log4cplus/copyright)
