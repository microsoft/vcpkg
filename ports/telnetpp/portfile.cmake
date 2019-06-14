if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF v1.2.4
  SHA512 16879fd377a7d13aac497bc9989c026acc1ed5b4eb9338d151d3d827c7c4c44fab84dd06c5fe55be4efe49a98ea46e62e80bbc51c8503d6ba1bf5534fee16c84
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
)

vcpkg_install_cmake()

# Remove duplicate header files and CMake input file
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/telnetpp/version.hpp.in)

# The install target in the upstream package does not install the binary output
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/telnetpp.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/telnetpp.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Move CMake installed configuration files and adjust for vcpkg debug location
file(COPY ${CURRENT_PACKAGES_DIR}/lib/telnetpp/telnetpp-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/telnetpp)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/telnetpp/telnetpp-config-release.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/telnetpp)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/telnetpp/telnetpp-config-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/telnetpp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/telnetpp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/telnetpp)

file(READ ${CURRENT_PACKAGES_DIR}/share/telnetpp/telnetpp-config-debug.cmake DEBUG_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}/lib/telnetpp.lib"
               "\${_IMPORT_PREFIX}/debug/lib/telnetpp.lib" DEBUG_CONFIG ${DEBUG_CONFIG})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/telnetpp/telnetpp-config-debug.cmake "${DEBUG_CONFIG}")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/telnetpp RENAME copyright)
