if (NOT VCPKG_TARGET_IS_LINUX AND NOT VCPKG_TARGET_IS_OSX)
    vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF 46fb877ef1618d9de9a9ba10cee107592b7cdb2d # 2021.1.1
    SHA512 0ad688694e5d78d2266e804d9366465534af81051f345d8309ab69c6df0f74a92a341de799bdd72edab850a64f265df6b428225ef94468b26235aab2e0247747
    HEAD_REF tbb_2019
    PATCHES
        fix-static-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTBB_TEST=OFF
        -DTBB_EXAMPLES=OFF
        -DTBB_STRICT=OFF
        -DTBB_WINDOWS_DRIVER=OFF
        -DTBB_NO_APPCONTAINER=OFF
        -DTBB4PY_BUILD=OFF
        -DTBB_CPF=OFF
        -DTBB_FIND_PACKAGE=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

# Delete unnamed libraries, they are deprecated
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/tbb${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
    "${CURRENT_PACKAGES_DIR}/tbb${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
