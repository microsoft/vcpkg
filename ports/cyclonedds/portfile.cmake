vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-cyclonedds/cyclonedds
    REF "${VERSION}"
    SHA512 2cc8668a5d42b4391edfee7310c868bc6a5cd0e96f478c270cc19cf9aeb86f057f43753c2c27f79912a5eca478404526bb9c7041e60669f7cf5a7fa931bf1d89
    HEAD_REF master
    PATCHES
        enable-security.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "ddsperf"                   BUILD_DDSPERF
        "deadline-missed"           ENABLE_DEADLINE_MISSED
        "ipv6"                      ENABLE_IPV6
        "idlc"                      BUILD_IDLC
        "lifespan"                  ENABLE_LIFESPAN
        "security"                  ENABLE_SECURITY
        "shm"                       ENABLE_SHM
        "source-specific-multicast" ENABLE_SOURCE_SPECIFIC_MULTICAST
        "ssl"                       ENABLE_SSL
        "topic-discovery"           ENABLE_TOPIC_DISCOVERY
        "type-discovery"            ENABLE_TYPE_DISCOVERY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/CycloneDDS")

if(BUILD_IDLC)
    vcpkg_copy_tools(TOOL_NAMES idlc AUTO_CLEAN)
endif()

if(BUILD_DDSPERF)
    vcpkg_copy_tools(TOOL_NAMES ddsperf AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
