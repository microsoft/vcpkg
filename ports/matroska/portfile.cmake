include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libmatroska
    REF release-1.4.9
    SHA512 0c2e7324d62e1fc28b00a899f1d2fda88a3de474ea25c51624d716b869db72b4645b64cc434a0bdb7cefdd63b354de59920d4011889554f95a2905020b139fb1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDISABLE_PKGCONFIG=1
)

vcpkg_install_cmake()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else ()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/matroska)
endif ()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/matroska RENAME copyright)
