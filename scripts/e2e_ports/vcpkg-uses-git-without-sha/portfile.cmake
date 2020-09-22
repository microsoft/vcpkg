set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://github.com/Microsoft/vcpkg"
    REF "95c0643813ad529c0fc1be8d66517b25ab131dd5"
    #SHA512
)
