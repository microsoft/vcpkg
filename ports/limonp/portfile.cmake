vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO playgithub/limonp
    REF 7f99b0c4c743f3e91e9c912c47a71c23967ef024
    SHA512 8cb6aa73f6268a1e9dc1f608832d6469a5ee88941ad827755cb1c7c1d6e3693bf1256fb3ad8bc571577601cd62c72e1fac630cb19ceb3d4a682c6b805f99f0a2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
