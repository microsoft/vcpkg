vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 4creators/jxrlib
    REF f7521879862b9085318e814c6157490dd9dbbdb4
    SHA512 f5617cbe73b6b905cc6bba181e6a3efedd59584f7a8c90e0f34db580cfdad4239a2ab753df4e221f26a5c0db51475b021052e3b9e3ab3673573573b1d57f3fdb
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
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

#install FindJXR.cmake file
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindJXR.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/jxr)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/jxr)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/jxr)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
