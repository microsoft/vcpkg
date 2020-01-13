if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "This port currently only supports x64 architecture")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/forge
    REF 650bf611de102a2cc0c32dba7646f8128f0300c8
    SHA512 2093464db0f3a7f0178f65bed37986a4df1117f1d7ad65157d525584490cdf234475f01ed1a2003a9e54bdc3b9e2e450808044a264c2284d67b8c2a353400027
    HEAD_REF master
	PATCHES fix-static_build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFG_BUILD_DOCS=OFF
        -DFG_BUILD_EXAMPLES=OFF
        -DFG_INSTALL_BIN_DIR=bin
        -DFG_WITH_FREEIMAGE=OFF
)

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/Forge/cmake)
endif()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/bin/* ${CURRENT_PACKAGES_DIR}/debug/bin/*)
list(FILTER DLLS EXCLUDE REGEX "forge\\.dll\$")
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/examples
    ${CURRENT_PACKAGES_DIR}/examples
    ${DLLS}
)

file(INSTALL ${SOURCE_PATH}/.github/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
