if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} doesn't currently support UWP.")
endif()

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LAStools/LAStools
    REF f15a702530e098b46c2eb3923f89a68ffa81e668
    SHA512 df5763b7c69721ba2a24fde2b4092e53136020b88ff4cc0d533279d709c55d7d16d8a4300f0b68829294d9311ed674af5b15306c4ded7a6310e55404737702e0
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
     file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

