#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/spdlog-0.12.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/gabime/spdlog/archive/v0.12.0.zip"
    FILENAME "v0.12.0.zip"
    SHA512 2ef251bf4496b3a17ca055f8ee087864b95eb1eb50d43cbe675bdb6f7cb2e5386460c222f4ed9b95d0f21fdb811f43e3b6a1cfaa45523760ff6125a329d8a02a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/share
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/spdlog/ ${CURRENT_PACKAGES_DIR}/share/spdlog/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# use vcpkg-provided fmt library
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/bundled)
file(READ ${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h SPDLOG_TWEAKME_CONTENTS)
string(REPLACE "// #define SPDLOG_FMT_EXTERNAL" "#define SPDLOG_FMT_EXTERNAL" SPDLOG_TWEAKME_CONTENTS ${SPDLOG_TWEAKME_CONTENTS})
file(WRITE ${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h ${SPDLOG_TWEAKME_CONTENTS})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spdlog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spdlog/LICENSE ${CURRENT_PACKAGES_DIR}/share/spdlog/copyright)
