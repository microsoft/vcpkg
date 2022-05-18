vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v3.0.1
    SHA512 065094c19cdf98b40f96a390e887542f895495562a91cdc28d68ce03690866d846ec87d320405312a2b97eacaa5351d3e55f0012bb9de40073c8d4444d82b0a1
    HEAD_REF devel
    PATCHES 
        fix-install-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCATCH_INSTALL_DOCS=OFF
        -DCATCH_INSTALL_EXTRAS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# We remove these folders because they are empty and cause warnings on the library installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/Catch2Main.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/Catch2Main.lib")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/Catch2Maind.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/Catch2Maind.lib")
endif()

file(GLOB SHARE_FILES "${CURRENT_PACKAGES_DIR}/share/catch2/*.cmake")
foreach(SHARE_FILE ${SHARE_FILES})
    vcpkg_replace_string("${SHARE_FILE}" "lib/Catch2Main" "lib/manual-link/Catch2Main")
endforeach()

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch_all.hpp>")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
