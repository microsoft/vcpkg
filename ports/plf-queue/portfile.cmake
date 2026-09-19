set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_queue
    REF c00f1052ac78beb9ab8b3f3eef28b3da953f9bde
    SHA512 10f5f1cf4d1d81bd0863df8b2cd9d4bd1b273b620b5c860c95284b26009248f2aef5cc6e766a810c30921431cb7fac3d4140911555143a7e07e48c145d466ce2
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/plf_queue.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)
