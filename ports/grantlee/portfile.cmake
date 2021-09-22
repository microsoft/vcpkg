vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steveire/grantlee
    REF v5.2.0 # v5.2.0
    SHA512 80b728b1770f60cd574805ec6fee8c6b86797da44c53f7889d3256cc52784e2cc5b7844e648f35f5cebbb82e22eed03dccf9cd7d0bdefdac9821e472d1bbbee3
    HEAD_REF master
)

set(Grantlee5_MAJOR_MINOR_VERSION_STRING "5.2" )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTS=off
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Grantlee5)
vcpkg_copy_pdbs()


foreach(GrantleeLib grantlee_defaultfilters.dll grantlee_defaulttags.dll grantlee_i18ntags.dll grantlee_loadertags.dll
                    grantlee_defaultfiltersd.dll grantlee_defaulttagsd.dll grantlee_i18ntagsd.dll grantlee_loadertagsd.dll)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/${GrantleeLib})
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/${GrantleeLib}
            ${CURRENT_PACKAGES_DIR}/bin/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/${GrantleeLib})
    endif()
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/${GrantleeLib})
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/${GrantleeLib}
            ${CURRENT_PACKAGES_DIR}/debug/bin/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING}/${GrantleeLib})
    endif()
endforeach()

if (WIN32)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
