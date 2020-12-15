#header-only library

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mjansson/mdns
	REF 1.1
	SHA512 03e4682d87e9c1157bba04e04a3dfbb2ed7e25df31f00834fbc7bf4275e5c7f7406e590c8bdc386a4e6fbe6a5667f700e146d39758aa8ee0a47f735547cacd31
	HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "example"   MDNS_BUILD_EXAMPLE
)


vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}    
)

vcpkg_install_cmake()


if ("example" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES "mdns_example"
        SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)