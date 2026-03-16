set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF v0.9.0
    SHA512 971d8e5d1c7ae899fc5e76ba14dc5ae4224dda7fc1110f1a93b55b99929453a671a4415214d44874a74f413668c8b422b4abad1b499454c08101604a4328206e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/tests/packaging"
)
vcpkg_cmake_build()
