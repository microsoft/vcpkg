vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(GAMMA_RELEASE_TAG "cc442ad0c5da369966cd937a96925c7b9a04e9e5")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "LancePutnam/Gamma"
    REF ${GAMMA_RELEASE_TAG}
    SHA512 431f17f053ca1c5ba0117b7ae7af8efae9df454593437de00dfea8ee04991b5701bee99d79deb074e60e397981a7fc1ce3476ec118d0f369e71e2cbaa696383d
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
