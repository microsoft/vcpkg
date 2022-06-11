vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF b125e31341660ea76ca51cc5013e52d8d34a1f27 # v1.6.5
    SHA512 c37fea47076a192161aacacf8694c5b6d487a1c2ebe1fa06acdd9948e42e1b1440d83ebe38f4ae3b86c90cb1aba76f7254cd434ea85e24484a9dacb6944511a9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
