vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libfido2
    REF 1.6.0
    SHA512 c473732a2f7ef54156097d315e44457d89056446ab3112a7c7a6fd99d5c2c8ae0ca2451ff9cd45be6c32de1ab335d6dfdb2b0c56b40cae9eb41391d18d83be4a
    HEAD_REF master
    PATCHES
      "find_packages.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBFIDO2_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBFIDO2_BUILD_SHARED)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
          -DBUILD_EXAMPLES=OFF
          -DBUILD_MANPAGES=OFF
          -DBUILD_STATIC_LIBS=${LIBFIDO2_BUILD_STATIC}
          -DBUILD_SHARED_LIBS=${LIBFIDO2_BUILD_SHARED}
          -DBUILD_TOOLS=OFF
    )

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(LIBFIDO2_BUILD_SHARED)
  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fido2.dll ${CURRENT_PACKAGES_DIR}/bin/fido2.dll)
  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fido2.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fido2.dll)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
