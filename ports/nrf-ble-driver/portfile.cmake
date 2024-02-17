if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(
"${PORT} currently requires the following libraries from the system package manager:
    libudev-dev
These can be installed on Ubuntu systems via sudo apt install libudev-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NordicSemiconductor/pc-ble-driver
    REF v${VERSION}-hex
    SHA512 1e8b5882aa3754a29a8f0ec11b8e70390db7ddf7bc50e1318adaaf4cd1ba2b787129d8003f8076ad39c35ec887ef3aeadbcb23fa5100b2be24956d118370cb84
    HEAD_REF master
    PATCHES
        001-arm64-support.patch
        support-arm64-osx.diff # from https://github.com/NordicSemiconductor/pc-ble-driver/pull/271
        gcc-11.2.0-compilation.patch # from https://github.com/NordicSemiconductor/pc-ble-driver/pull/272
)

# Ensure that git is found within CMakeLists.txt by appending vcpkg's git executable dirpath to $PATH.
# Git should always be available as it is downloaded during the bootstrap phase.
# Append instead of prepend to $PATH to honor the user's git executable as a general rule.
vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_EXE_PATH "${GIT}" DIRECTORY)
vcpkg_add_to_path("${GIT_EXE_PATH}")

set(OPTIONS)
if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(OPTIONS "-DARCH=${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISABLE_EXAMPLES=ON
        -DDISABLE_TESTS=ON
        -DNRF_BLE_DRIVER_VERSION=${VERSION}
        -DCONNECTIVITY_VERSION=${VERSION}
        ${OPTIONS}
    MAYBE_UNUSED_VARIABLES
        DISABLE_EXAMPLES
        DISABLE_TESTS
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

# Copy hex files into shared folder for package
foreach(HEX_DIR IN ITEMS "sd_api_v2" "sd_api_v3" "sd_api_v5" "sd_api_v6")
    set(TARGET_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/hex/${HEX_DIR}")
    file(MAKE_DIRECTORY "${TARGET_DIRECTORY}")
    file(INSTALL "${SOURCE_PATH}/hex/${HEX_DIR}" DESTINATION "${TARGET_DIRECTORY}/..")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
