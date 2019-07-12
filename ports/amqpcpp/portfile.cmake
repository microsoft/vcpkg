include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CopernicaMarketingSoftware/AMQP-CPP
    REF 5a648fe2d8df7dacc389fdc83be5d35e616a06c1
    SHA512 87dbce33a1389936482bfdc5d23d02f41097ef1a154100e4ed8c940d2548ba7b7312a456dcdcd19b2fe04a0dc2dbcbe70c57ade635d514a7b3a4033584c6382a
    HEAD_REF master
    PATCHES
        find-openssl.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(LINUX_TCP ON)
else()
    set(LINUX_TCP OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DAMQP-CPP_BUILD_SHARED=OFF
        -DAMQP-CPP_LINUX_TCP=${LINUX_TCP}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/amqpcpp RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
