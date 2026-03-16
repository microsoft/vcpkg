set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF v0.9.1
    SHA512 cd2f1208f318a8ed28109618b623f574767241c5dd6da63458f8921793f97f6553636a50fc05c55f5223664321bb1f2a9e8b7791738037b0d7d985d8b877e976
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/tests/packaging"
)
vcpkg_cmake_build()
