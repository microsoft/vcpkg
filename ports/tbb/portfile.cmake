if (NOT VCPKG_TARGET_IS_LINUX)
    vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF 46fb877ef1618d9de9a9ba10cee107592b7cdb2d # v2021.1.1
    SHA512 0ad688694e5d78d2266e804d9366465534af81051f345d8309ab69c6df0f74a92a341de799bdd72edab850a64f265df6b428225ef94468b26235aab2e0247747
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTBB_TEST=OFF
        -DTBB_BENCH=OFF      
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/TBB")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
