vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF v2021.05.31.00
    SHA512 529fa0e32cb0aecf59fb90f1d8c9bf284c6749169713c365ca06bbf54ed12a8978042af05094214c42945d372e2457bb2bfc2acc543f6538b296a25eb66d7186
    HEAD_REF master
)

# Prefer installed config files
file(REMOVE
    ${SOURCE_PATH}/fizz/cmake/FindGflags.cmake
    ${SOURCE_PATH}/fizz/cmake/FindGlog.cmake
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/fizz"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fizz)
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake" "lib/cmake/fizz" "share/fizz")

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/fizz/tool/test" "${CURRENT_PACKAGES_DIR}/include/fizz/util/test")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)