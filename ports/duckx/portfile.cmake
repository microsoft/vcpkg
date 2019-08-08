include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO amiremohamadi/DuckX
    REF 98c946ad13559c03e9c7f2b050b9f70d5caf509e
    SHA512 20e8970a1faff6e2ff5bc106bd038396d05ace3517ac83583712263870c4b007ebc407b5d69c482f7117ac155aa85f9928d5ee524f75897e8e12eb3659d16c15
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/duckx)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/duckx RENAME copyright)
