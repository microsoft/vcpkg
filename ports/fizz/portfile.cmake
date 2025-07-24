vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF "v${VERSION}"
    SHA512 9d036d3af106780989cb2f09abfb876ad9ba2f812648aec5dbff7ca79db1b60fbbe6b296119fedba704a23a1647f826040b225ff8d9e13cbf0f9d19c39d99dd0
    HEAD_REF main
    # PATCHES
    #     fix-build.patch
)

# Prefer installed config files
file(REMOVE
    "${SOURCE_PATH}/fizz/cmake/FindGMock.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindGflags.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindGlog.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindLibevent.cmake"
)

# Fix libevent dependency issue
vcpkg_replace_string("${SOURCE_PATH}/fizz/CMakeLists.txt" 
    "find_package(Libevent MODULE REQUIRED)"
    "find_package(Libevent CONFIG REQUIRED)"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/fizz"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fizz)
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake" "lib/cmake/fizz" "share/fizz")

# Fix sodium dependency issue - replace Sodium with unofficial-sodium
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake" 
    "find_dependency(Sodium)"
    "find_dependency(unofficial-sodium CONFIG)"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/fizz/crypto/aead/test/facebook"
    "${CURRENT_PACKAGES_DIR}/include/fizz/record/test/facebook"
    "${CURRENT_PACKAGES_DIR}/include/fizz/server/test/facebook"
    "${CURRENT_PACKAGES_DIR}/include/fizz/tool/test"
    "${CURRENT_PACKAGES_DIR}/include/fizz/util/test")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
