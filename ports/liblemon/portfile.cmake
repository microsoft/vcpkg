include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VERSION ed2c21cbd6ef)

vcpkg_download_distfile(ARCHIVE
    URLS "http://lemon.cs.elte.hu/hg/lemon/archive/${VERSION}.zip"
    FILENAME "lemon-${VERSION}.zip"
    SHA512 029640e4f791a18068cb2e2b4e794d09822d9d56fb957eb3e2cceae3a30065c0041a31c465637cfcadf7b2473564070b34adc88513439cdf9046831854e2aa70
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        "cmake.patch"
        "fixup-targets.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLEMON_ENABLE_GLPK=OFF
        -DLEMON_ENABLE_ILOG=OFF
        -DLEMON_ENABLE_COIN=OFF
        -DLEMON_ENABLE_SOPLEX=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/lemon/cmake TARGET_PATH share/lemon)

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(COPY ${EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblemon/)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/liblemon)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblemon RENAME copyright)
