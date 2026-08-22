vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO amrayn/licensepp
    REF v${VERSION}
    SHA512 a27b8e669cff2ce06dfb0b2b6f961406e4c488f4a55fc086754274c719632d53942d88192010b6af8cc46784aee6a7b5c40780792e9d6f0d51ec3da76576f259
    HEAD_REF master
    PATCHES
        add-stdint.diff
        remove-werror.diff
        devendoring.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/FindCryptoPP.cmake" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtest=OFF
        -Dtravis=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
