# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xsimd
    REF 7.2.2
    SHA512 76e98b8f12e5e388108858e5aef687a976a4c4614de9d9d6c854a6edb2ddda92c6b941a466a0b4d933c6d049c89937edfc23bbd8850b81c6293f40f8dc5bbe87
    HEAD_REF master
)

if("xcomplex" IN_LIST FEATURES)
    set(ENABLE_XTL_COMPLEX ON)
else()
    set(ENABLE_XTL_COMPLEX OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_FALLBACK=OFF
        -DENABLE_XTL_COMPLEX=${ENABLE_XTL_COMPLEX}
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
