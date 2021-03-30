if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(BUILD_TESTS OFF)

vcpkg_from_github(
    OUT_SOURCE_PATH
    SOURCE_PATH
    REPO
    hrantzsch/keychain
    REF
    v1.2.0
    SHA512
    8faed892e6d84ad3d31056682dc4bb18ff8c12a3eababfa58e3c01ad369da1d9b0772198e15196b49b4de895a44ff7e96a59b56b87011f95ec88bcae819fe6ff
)

vcpkg_configure_cmake(
    SOURCE_PATH
    ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
    -DBUILD_TESTS:BOOL=${BUILD_TESTS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/keychain
    RENAME copyright)
