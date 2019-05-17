include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/vlfeat
    REF 1.0.1
    SHA512 ed5f8d2adbedaceebf299400d4269d458f51ba263ed1c8edc285bd461183b0346dbca53e116ae225ab410b5494bbc2c6b2d9895d55f5f03c7d222320a2674df7
    HEAD_REF cDc
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_DYNAMIC_LIBS}
        -DBUILD_STATIC_RUNTIME=${BUILD_STATIC_CRT}
        -DBUILD_APPS=OFF
)

vcpkg_install_cmake()

if(WIN32)
	vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")
else()
	vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/vlfeat")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/vlfeat RENAME copyright)
