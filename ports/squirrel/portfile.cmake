vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO albertodemichelis/squirrel
    HEAD_REF master
    REF cf0516720e1fa15c8cbd649aebd1924f6e7084cc
    SHA512 6127d25e40217188abe14e30943f131f0e03923cf095f3df276a9c36b48495cf5d84bb1e30b39fa23bd630d905b6a6b4c70685dfb7a999b8b0c12e28c2e3b902
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "interpreter" BUILD_SQ
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DDISABLE_DYNAMIC=${DISABLE_DYNAMIC}
        -DDISABLE_STATIC=${DISABLE_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/squirrel)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_SQ)
    if(BUILD_STATIC)
        vcpkg_copy_tools(
            TOOL_NAMES sq
            AUTO_CLEAN
        )
    elseif(BUILD_DYNAMIC)
        vcpkg_copy_tools(
            TOOL_NAMES sq sq_static
            AUTO_CLEAN
        )
    endif()
endif()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
