#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.2.1
    SHA512 418f91efc207fa227558212d82c41639c0bb59e84ea47447e0b6276c4842e97f1f8aaf5802c071ef15d80ec525e317e70b6a39661a6c96ab39d33d9bd1570da1
    HEAD_REF v1.x
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/spdlog)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# use vcpkg-provided fmt library
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/bundled)
file(READ ${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h SPDLOG_TWEAKME_CONTENTS)
string(REPLACE "// #define SPDLOG_FMT_EXTERNAL" "#define SPDLOG_FMT_EXTERNAL" SPDLOG_TWEAKME_CONTENTS "${SPDLOG_TWEAKME_CONTENTS}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h "${SPDLOG_TWEAKME_CONTENTS}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spdlog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spdlog/LICENSE ${CURRENT_PACKAGES_DIR}/share/spdlog/copyright)
