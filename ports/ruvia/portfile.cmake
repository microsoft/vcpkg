vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyird/Ruvia
    REF "v${VERSION}"
    SHA512 1a8dd710458019121f4f06e79832dc5163929c1a165d22792ef8e988daf141d0cc75924b82304ce75115ee494a0a49fbddf0488041f98eedd275d5ceea600d36
    HEAD_REF main
    PATCHES
        respect-msvc-runtime.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jwt RUVIA_ENABLE_JWT
        mariadb RUVIA_ENABLE_MARIADB
        redis RUVIA_ENABLE_REDIS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DRUVIA_BUILD_EXAMPLES=OFF
        -DRUVIA_BUILD_TECHEMPOWER=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ruvia CONFIG_PATH lib/cmake/ruvia)
vcpkg_copy_pdbs()

set(RUVIA_CONFIG "${CURRENT_PACKAGES_DIR}/share/ruvia/ruviaConfig.cmake")
file(READ "${RUVIA_CONFIG}" RUVIA_CONFIG_CONTENTS)
string(REPLACE
    [=[get_filename_component(_ruvia_prefix "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)]=]
    [=[get_filename_component(_ruvia_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)]=]
    RUVIA_CONFIG_CONTENTS
    "${RUVIA_CONFIG_CONTENTS}"
)
string(REGEX REPLACE
    [=[IMPORTED_LOCATION "\$\{_ruvia_prefix\}/lib/([^"]+)"]=]
    [=[IMPORTED_CONFIGURATIONS "Debug;Release"
        IMPORTED_LOCATION_RELEASE "${_ruvia_prefix}/lib/\1"
        IMPORTED_LOCATION_DEBUG "${_ruvia_prefix}/debug/lib/\1"]=]
    RUVIA_CONFIG_CONTENTS
    "${RUVIA_CONFIG_CONTENTS}"
)
file(WRITE "${RUVIA_CONFIG}" "${RUVIA_CONFIG_CONTENTS}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
