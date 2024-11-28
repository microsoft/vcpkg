if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RealTimeChris/DiscordCoreAPI
    REF "v${VERSION}"
    SHA512 344e960491e17e9626f6ab4a42f28fe59842c0c15cf32ef2508e850099105667c651feaa6dd642207413fbeac43283310fe2b9a98a2ebfd4a49716da43e5cade
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
    # Due to CMake/DCADetectArchitecture.cmake invoking a sub-CMake and using the source tree as the target
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
