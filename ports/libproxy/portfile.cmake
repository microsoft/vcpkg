include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libproxy/libproxy
    REF 527071df60d5c03e58768c30c3745ac69ebda318
    SHA512 1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/proxywrapper)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/proxywrapper/COPYING ${CURRENT_PACKAGES_DIR}/share/proxywrapper/copyright)
