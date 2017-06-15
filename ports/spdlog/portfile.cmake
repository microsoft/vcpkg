#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v0.13.0
    SHA512 5bb89cbeb17a054832ce70f6013d54e7641c1aa36cbad08388b4a2e63f4851943edfe292551ff01de6de1ed6325617384325a67f3e1024f346c6d22a1148c80c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Move cmake files, ensuring they will be 3 directories up the import prefix
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/spdlog)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/spdlog/ ${CURRENT_PACKAGES_DIR}/share/spdlog/cmake)

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
