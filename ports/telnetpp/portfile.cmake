if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF 8dc780579293153ad2ae9ad6943815c050d4c659
  SHA512 280a8e6c0392f5822b05968520d176d1510f00c12a2502f6039f4f1f78a558e61f825a231fb70b7de6fd21a18b24734eea3ba36a24b29f2a7e9856b1f4de5217
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
