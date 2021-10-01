vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO albertodemichelis/squirrel
    HEAD_REF master
    REF 23a0620658714b996d20da3d4dd1a0dcf9b0bd98
    SHA512 205ba0b2b37ca2133f8c1b3024a3a34186697998714140d409006ae0f5facc76b2664dbbad33bbc51c86199e2524bd0cd905b8941e306db892a50a58f1b96371
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
