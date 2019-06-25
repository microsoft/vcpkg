include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 4creators/jxrlib
    REF e922fa50cdf9a58f40cad07553bcaa2883d3c5bf
    SHA512 15ed099e5f80571ebd86e115ed1c2dd18be4d6faa8b5f19212ea89582ec37e0ffa0629d80470fcb49f1c605996ea6ce76fd0dd95d9edee458ba290dff4d21537
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES Darwin AND NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES Linux)
  # The file guiddef.h is part of the Windows SDK,
  # we then remove the local copy shipped with jxrlib
  file(REMOVE ${SOURCE_PATH}/common/include/guiddef.h)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

#install FindJXR.cmake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindJXR.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/jxr)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/jxr)
