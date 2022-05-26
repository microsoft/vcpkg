vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Cisco-Talos/clamav-devel
  REF clamav-0.105.0
  SHA512 fb3f9bda2112c72266547e6b052aeefb30b560a77f3d768ac8c09b091cfd752592c53a14ef7aa6f9c79f4d6e74b33892a22234c0d5a3ff8a411ae89a399f736b
  FILE_DISAMBIGUATOR 1
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
      -DENABLE_LIBCLAMAV_ONLY=ON
      -DENABLE_SHARED_LIB=ON
      -DENABLE_STATIC_LIB=OFF
      -DENABLE_TESTS=OFF
      -DENABLE_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

#Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/COPYING.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/NEWS.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/NEWS.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/COPYING.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

#Release
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")

file(RENAME "${CURRENT_PACKAGES_DIR}/clamav.lib" "${CURRENT_PACKAGES_DIR}/lib/clamav.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/clammspack.lib" "${CURRENT_PACKAGES_DIR}/lib/clammspack.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/clamunrar.lib" "${CURRENT_PACKAGES_DIR}/lib/clamunrar.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/clamunrar_iface.lib" "${CURRENT_PACKAGES_DIR}/lib/clamunrar_iface.lib")

file(RENAME "${CURRENT_PACKAGES_DIR}/libclamav.dll" "${CURRENT_PACKAGES_DIR}/bin/libclamav.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/libclammspack.dll" "${CURRENT_PACKAGES_DIR}/bin/libclammspack.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/libclamunrar.dll" "${CURRENT_PACKAGES_DIR}/bin/libclamunrar.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/libclamunrar_iface.dll" "${CURRENT_PACKAGES_DIR}/bin/libclamunrar_iface.dll")

#Debug
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")

file(RENAME "${CURRENT_PACKAGES_DIR}/debug/clamav.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/clamav.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/clammspack.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/clammspack.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/clamunrar.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/clamunrar.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/clamunrar_iface.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/clamunrar_iface.lib")

file(RENAME "${CURRENT_PACKAGES_DIR}/debug/libclamav.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/libclamav.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/libclammspack.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/libclammspack.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/libclamunrar.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/libclamunrar.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/libclamunrar_iface.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/libclamunrar_iface.dll")

# On Linux, clamav will still build and install clamav-config
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

