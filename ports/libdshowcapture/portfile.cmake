include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO obsproject/libdshowcapture
    REF cba07c63810f51a58f6fb7f2e3b0fb162b5a6313
    SHA512 962f5886f637f06580db9b90d238cdb76976846c5b1d49112910fda0da689788abec1d1703aa4e91ee4be57f328eb8183c04f94119662e1243269ae66f023c84
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake(TARGET libdshowcapture)

# Copy files
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libdshowcapture RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libdshowcapture.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libdshowcapture.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libdshowcapture.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libdshowcapture.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/dshowcapture.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()
