vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexif/libexif
    REF libexif-0_6_22-release
    SHA512 6c63abe2734c9e83fb04adb00bdd77f687165007c0efd0279df26c101363b990604050c430c7dd73dfa8735dd2fd196334d321bdb114d4869998f21e7bed5b43
    HEAD_REF master
    PATCHES add-missing-_stdint-h.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libexif.def    DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
