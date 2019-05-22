include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libmatroska
    REF release-1.5.0
    SHA512 956cee9cc6f752f7328ef6837dbbf342a5001bf5467b1dd5ac6ececf777c497b9d97b83a872b6bdff9927d2c464b1c22dc32803d7124f009c83e445d10dacc55
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDISABLE_PKGCONFIG=1
)

vcpkg_install_cmake()

if (WIN32)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else ()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/matroska)
endif ()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/matroska RENAME copyright)
