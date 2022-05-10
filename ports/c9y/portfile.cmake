vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/c9y
    REF v0.3.0
    SHA512 9d105f5d8f93856d6104663704944e0456c779c9ae6469d4ad9a40f6e451065376a44e4efb61c2e0b5e79cb2f3ae78de72209b6668d56d7df7992275f2168336
    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
