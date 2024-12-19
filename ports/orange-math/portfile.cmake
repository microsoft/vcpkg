vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/omath
    REF "v${VERSION}"
    SHA512 467b1abbdf5b9a7f49ed50824eaa4641f05d6088e84f40320b5c82a1bdbf685cc8d0f0a4f4ab6be49e3a8ed13103ee3e808dde3b556a00742f7b53c519c183e3
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/cmake/omathConfig.cmake.in"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/source/CMakeLists.txt"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/source/prediction/CMakeLists.txt"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/source/pathfinding/CMakeLists.txt"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/source/projection/CMakeLists.txt"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/source/collision/CMakeLists.txt"
    "omath"
    "orange-math"
)

vcpkg_replace_string("${SOURCE_PATH}/source/engines/Source/CMakeLists.txt"
    "omath"
    "orange-math"
)

file(RENAME "${SOURCE_PATH}/cmake/omathConfig.cmake.in" "${SOURCE_PATH}/cmake/orange-mathConfig.cmake.in")

file(READ "${SOURCE_PATH}/cmake/orange-mathConfig.cmake.in" cmake_config)

file(WRITE "${SOURCE_PATH}/cmake/orange-mathConfig.cmake.in"
"${cmake_config}
check_required_components(orange-math)
")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOMATH_BUILD_TESTS=OFF
        -DOMATH_THREAT_WARNING_AS_ERROR=OFF
        -DOMATH_BUILD_AS_SHARED_LIBRARY=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/orange-math")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
