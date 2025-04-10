vcpkg_from_github(
    OUT_SOURCE_PATH REPO_ROOT
    REPO Robertleoj/slam_dunk
    REF v0.1.0
    SHA512 32749611d6e7ba66fe240b7fb162deb6ceb035385c88cf1aa7f7f24eee98500cdfa639733ccccaecb7d0cead77c1099bcc420d78fce309686ac4b0b283b79730
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
