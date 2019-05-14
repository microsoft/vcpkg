include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-netlib/cpp-netlib
    REF cpp-netlib-0.13.0-rc3
    SHA512 ddc4178381ebc4179bc243d19ecd4c7e424a61a7b75b6fd59d1f9e9fbcc1383c0afba97bcbef1b791eedb5a7a2cd63a633454f3848dfc5d76a41cc8a2c6ed302
    HEAD_REF master
)

 vcpkg_configure_cmake(
      SOURCE_PATH ${SOURCE_PATH}
      PREFER_NINJA
	  OPTIONS
      -DCPP-NETLIB_BUILD_TESTS=off
      -DCPP-NETLIB_BUILD_EXAMPLES=off
	  
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(WIN32 AND NOT CYGWIN)
  vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/${PORT})
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cppnetlib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

