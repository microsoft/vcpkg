vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO duilib/duilib
    REF d7f3a331a0fc6ba48429cd9e5c427570cc73bc35
    SHA512 6381cac467d42e4811859411a5fa620e52075622e8fbec38a6ab320c33bc7d6fdddc809c150d6a10cc40c55a651345bda9387432898d24957b6ab0f5c4b5391c
    HEAD_REF master
    PATCHES 
        "fix-post-build-errors.patch"
        "fix-arm-build.patch"
        "fix-encoding.patch"
        "enable-static.patch"
        "enable-unicode-for-vcpkg.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/DuiLib
    PREFER_NINJA
    NO_CHARSET_FLAG
)

vcpkg_build_cmake()

file(INSTALL ${SOURCE_PATH}/DuiLib DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/duilib.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/duilib.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
else()
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/duilib.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/duilib.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/duilib.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/duilib.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/duilib.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/duilib.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
