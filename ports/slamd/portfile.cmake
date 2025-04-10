vcpkg_from_github(
    OUT_SOURCE_PATH REPO_ROOT
    REPO Robertleoj/slam_dunk
    REF v0.1.0
    SHA512 5c71b53e30b4b57e190298e6c4fdef7906e97dece329659407018f95c42163b96402cb81bec069251489b5f4af972591e7b126b913e9e09b6b1b90179aab5063
)

# for local usage
# set(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")

set(SOURCE_DIR "${REPO_ROOT}/slamd")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_DIR}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "slamd")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${REPO_ROOT}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${SOURCE_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
