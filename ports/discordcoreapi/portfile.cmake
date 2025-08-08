if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RealTimeChris/DiscordCoreAPI
    REF "v${VERSION}"
    SHA512 d977ed7d8805f0b110450d3baf0256eae11ecc25947496c657a9c9b17aa9222db92435f28ebd924c166927e4714b3e9ae388f64836175cc96b78b08315031ede
    HEAD_REF main
)

# discordcoreapi consumes extreme amounts of memory (>9GB per .cpp file). With our default
# concurrency values this causes hanging and/or OOM killing on Linux build machines and
# warnings on the Windows machines like:
# #[warning]Free memory is lower than 5%; Currently used: 99.99%
# #[warning]Free memory is lower than 5%; Currently used: 99.99%
# #[warning]Free memory is lower than 5%; Currently used: 99.99%
# Cut the requested concurrency in quarter to avoid this.
if(VCPKG_CONCURRENCY GREATER 4)
    math(EXPR VCPKG_CONCURRENCY "${VCPKG_CONCURRENCY} / 4")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
