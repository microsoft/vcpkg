include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liteserver/binn
    REF 9d7a26800cc5285818502778a6b3905d65664a1d # 2.0
    SHA512 2507303dfa8b1815507e2ff96482ef94792927a5004195a55c5dadf1fcc29bfa474f8f2a8fb4c285132e782fb54b836d5113e431d25dc23aadbb148d588f26c4
    HEAD_REF master
    PATCHES
        0001_fix_uwp.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

file(INSTALL ${SOURCE_PATH}/src/binn.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/binn)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/binn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/binn/LICENSE ${CURRENT_PACKAGES_DIR}/share/binn/copyright)
