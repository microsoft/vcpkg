vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF "${VERSION}"
    #[[
        Attention: pdal-dimbuilder must be updated together with pdal
    #]]
    SHA512 16350288122aae0c6f59bf91d1ee631b85e9653d76b706d27427706484fefbbe5f7fa3bc3ec1f1fda0fd37fb6cb0388d3ed712db614c22aff5dcd66b4998ff1e
    HEAD_REF master
    PATCHES
        dependencies.diff
        external-dimbuilder.diff
        find-library-suffix.diff
        no-rpath.patch
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/cmake/modules/FindCURL.cmake"
    "${SOURCE_PATH}/cmake/modules/FindGeoTIFF.cmake"
    "${SOURCE_PATH}/cmake/modules/FindICONV.cmake"
    "${SOURCE_PATH}/cmake/modules/FindZSTD.cmake"
    "${SOURCE_PATH}/vendor/eigen"
    "${SOURCE_PATH}/vendor/h3"
    "${SOURCE_PATH}/vendor/nanoflann"
    "${SOURCE_PATH}/vendor/nlohmann"
    "${SOURCE_PATH}/vendor/schema-validator"
    "${SOURCE_PATH}/vendor/utfcpp"
)
# PDAL uses namespace 'NL' for nlohmann
file(COPY "${CURRENT_INSTALLED_DIR}/include/nlohmann" DESTINATION "${SOURCE_PATH}/vendor/nlohmann/")
file(APPEND "${SOURCE_PATH}/vendor/nlohmann/nlohmann/json.hpp" "\nnamespace NL = nlohmann;\n")
file(APPEND "${SOURCE_PATH}/vendor/nlohmann/nlohmann/json_fwd.hpp" "\nnamespace NL = nlohmann;\n")
file(WRITE "${SOURCE_PATH}/pdal/JsonFwd.hpp" "/* vcpkg redacted */\n#include <nlohmann/json_fwd.hpp>\nnamespace NL = nlohmann;\n")
file(MAKE_DIRECTORY "${SOURCE_PATH}/vendor/nlohmann/schema-validator")
file(WRITE "${SOURCE_PATH}/vendor/nlohmann/schema-validator/json-schema.hpp" "/* vcpkg redacted */\n#include <nlohmann/json-schema.hpp>\n")

unset(ENV{OSGEO4W_HOME})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        draco       BUILD_PLUGIN_DRACO
        e57         BUILD_PLUGIN_E57
        hdf5        BUILD_PLUGIN_HDF
        lzma        WITH_LZMA
        pgpointcloud BUILD_PLUGIN_PGPOINTCLOUD
        zstd        WITH_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        "-DDIMBUILDER_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/pdal-dimbuilder/dimbuilder${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DPDAL_PLUGIN_INSTALL_PATH=.
        -DWITH_TESTS:BOOL=OFF
        -DWITH_COMPLETION:BOOL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Libexecinfo:BOOL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libunwind:BOOL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PDAL)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Install and cleanup executables
file(GLOB pdal_unsupported
    "${CURRENT_PACKAGES_DIR}/bin/*.bat"
    "${CURRENT_PACKAGES_DIR}/bin/pdal-config"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*.bat"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
    "${CURRENT_PACKAGES_DIR}/debug/bin/pdal-config"
)
file(REMOVE ${pdal_unsupported})
vcpkg_copy_tools(TOOL_NAMES pdal AUTO_CLEAN)

# Post-install clean-up
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/pdal/filters/private/csf"
    "${CURRENT_PACKAGES_DIR}/include/pdal/filters/private/miniball"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(arbiter_license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/arbiter LICENSE")
file(COPY_FILE "${SOURCE_PATH}/vendor/arbiter/LICENSE" "${arbiter_license}")

set(kazhdan_license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/kazhdan license (PoissonRecon.h)")
file(READ "${SOURCE_PATH}/vendor/kazhdan/PoissonRecon.h" license)
string(REGEX REPLACE "^/\\*\n|\\*/.*\$" "" license "${license}")
file(WRITE "${kazhdan_license}" "${license}")

set(lazperf_license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lazperf license (lazperf.hpp)")
file(READ "${SOURCE_PATH}/vendor/lazperf/lazperf.hpp" license)
string(REGEX REPLACE "^/\\*\n|\\*/.*\$" "" license "${license}")
file(WRITE "${lazperf_license}" "${license}")

set(lepcc_license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/LEPCC license (LEPCC.h)")
file(READ "${SOURCE_PATH}/vendor/lepcc/src/LEPCC.h" license)
string(REGEX REPLACE "^/\\*\n|\\*/.*\$" "" license "${license}")
file(WRITE "${lepcc_license}" "${license}")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
    "${arbiter_license}"
    "${kazhdan_license}"
    "${lazperf_license}"
    "${lepcc_license}"
)
