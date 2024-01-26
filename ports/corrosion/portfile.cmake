set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corrosion-rs/corrosion
    REF "v${VERSION}"
    SHA512 9ed7449f50c9ca5991af3867f8d05db135202848da4803f036d286bc5bfc2f6b7fcc9fa4b1e9458a619064f12abbd5f5f3ea506a83142677ced551d7e976894b
    HEAD_REF master
)

find_program(CARGO cargo PATHS "$ENV{HOME}/.cargo/bin/")
if (CARGO STREQUAL "CARGO-NOTFOUND")
    message("Could not find cargo, trying to install via https://rustup.rs/.")
    execute_process(COMMAND bash "-c" "curl -sSf https://sh.rustup.rs | sh -s -- -y")
endif()

# Redo with the install process and just ignore the warnings?
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Corrosion)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

#include(CMakePackageConfigHelpers)
#
##configure_package_config_file(
##	${SOURCE_PATH}/cmake/CorrosionConfig.cmake.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/CorrosionConfig.cmake
##    INSTALL_DESTINATION
##        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
##)
#
#write_basic_package_version_file(
#    "${CURRENT_PACKAGES_DIR}/share/${PORT}/CorrosionConfigVersion.cmake"
#    VERSION v${VERSION}
#    COMPATIBILITY
#        SameMinorVersion # TODO: Should be SameMajorVersion when 1.0 is released
#    ARCH_INDEPENDENT
#)
#
#file(INSTALL
#        ${SOURCE_PATH}/cmake/Corrosion.cmake
#     DESTINATION
#        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
#     RENAME
#        CorrosionConfig.cmake
#)
#
#list(APPEND CMAKE_MODULE_PATH "${CURRENT_PACKAGED_DIR}/share/${PORT}/cmake")
#
##file(INSTALL
##        ${SOURCE_PATH}/cmake/CorrosionGenerator.cmake
##        ${SOURCE_PATH}/cmake/FindRust.cmake
##    DESTINATION
##        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
##)
#
## These CMake scripts are needed both for the install and as a subdirectory
#file(INSTALL
#        ${SOURCE_PATH}/cmake/Corrosion.cmake
#        ${SOURCE_PATH}/cmake/CorrosionGenerator.cmake
#        ${SOURCE_PATH}/cmake/FindRust.cmake
#    DESTINATION
#	"${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake"
#)
#
#vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
#file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

