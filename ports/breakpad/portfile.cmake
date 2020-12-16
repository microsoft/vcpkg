vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF 9c4671f2e3a63c0f155d9b2511192d0b5fa7f760 # accessed on 2020-09-14
    SHA512 4c9ed9b675a772f9a6a84692865381130901820cb395b725511e7a9e2cbf4aaa5212a9ef5f87086baf58bb9d729082232b564bd827a205f87b5c1ffc1c53892a
    HEAD_REF master
    PATCHES
        fix-unique_ptr.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-breakpad TARGET_PATH share/unofficial-breakpad)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
