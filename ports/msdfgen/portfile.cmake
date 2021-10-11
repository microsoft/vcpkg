# No symbols are exported in msdfgen source
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if ("tools" IN_LIST FEATURES AND VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "Tools cannot be built on UWP.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Chlumsky/msdfgen
    REF v1.9.1
    SHA512 7A721B38027548F66D1C3EB862C1F27EA0A431C325119504D072BA6D7ED87539BA4D6020C663354B7B82BA48725D77CC642DB05FB596749292A2A12BE21CE528
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools MSDFGEN_BUILD_MSDFGEN_STANDALONE
        openmp MSDFGEN_USE_OPENMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/msdfgen)

# move exe to tools
if("tools" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_copy_tools(TOOL_NAMES msdfgen AUTO_CLEAN)
endif()

# cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# license
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
