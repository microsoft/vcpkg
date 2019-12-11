#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF v1.0.5
    SHA512 2c625a6dc6f7b1b578d74f97b0ccec90856caaedb0725db4c5892cfaa33e77cd502b01ee26b1789017c459f4b0a03eaf16ae859dc51ad4e6f362aca7c5833995
    HEAD_REF master
)

# Use brynet's own build process, skipping examples and tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_INSTALL_DIR:STRING=cmake
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brynet)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/brynet/LICENSE ${CURRENT_PACKAGES_DIR}/share/brynet/copyright)
