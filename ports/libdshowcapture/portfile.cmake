vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO obsproject/libdshowcapture
    REF 8878638324393815512f802640b0d5ce940161f1
    SHA512 bbb9fa169bffce4f6405b8332524267f10b3e6e2dcaddcddf7ef73ffb7a6409ef4c6a13f599cab814cbf42c22690f9e24e988666886535ef9fdfb851fdb50a5c
    HEAD_REF master
    PATCHES
        fix_build.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH DEP_SOURCE_PATH
    REPO elgatosf/capture-device-support
    REF fe9630974d47f51bf54826e72fb8b654e620aa93
    SHA512 971185ffaf0c5777c060d3cf49ee8f907aebc8191e3ada9c9f3c4c0d553c257d13e2828c991985b9d47a446d003b26664ecec2c18c0e6c66dfdba904baee0ae6
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/external/capture-device-support")
file(RENAME "${DEP_SOURCE_PATH}" "${SOURCE_PATH}/external/capture-device-support")
file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build(TARGET libdshowcapture)

# Copy files
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(NOT VCPKG_BUILD_TYPE)
      file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libdshowcapture.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libdshowcapture.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()
if(NOT VCPKG_BUILD_TYPE)
  file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libdshowcapture.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libdshowcapture.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/dshowcapture.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_copy_pdbs()
