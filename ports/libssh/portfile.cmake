include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "WindowsStore not supported")
endif()
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libssh-0.8.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libssh.org/files/0.8/libssh-0.8.1.tar.xz"
    FILENAME "libssh-0.8.1.tar.xz"
    SHA512 6630d0b101dc109116ba7a6cffb00db1bc9b5bc6004c843c5361d3d97c6cf4c323129ebf3bbf25ab2fc1961b74520490d7a16999504849c07b26a25679724b93
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/build-one-flavor.patch
        ${CMAKE_CURRENT_LIST_DIR}/only-one-flavor-threads.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" WITH_STATIC_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_STATIC_LIB=${WITH_STATIC_LIB}
        -DWITH_MBEDTLS=ON
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTING=OFF
        -DWITH_NACL=OFF
        -DWITH_GSSAPI=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/static/ssh.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/static/ssh.lib ${CURRENT_PACKAGES_DIR}/lib/ssh.lib)
    endif()
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/static/ssh.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/static/ssh.lib ${CURRENT_PACKAGES_DIR}/debug/lib/ssh.lib)
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(READ ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h _contents)
    string(REPLACE "#ifdef LIBSSH_STATIC" "#if 1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h "${_contents}")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/static ${CURRENT_PACKAGES_DIR}/debug/lib/static)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# The installed cmake config files are nonfunctional (0.7.5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh RENAME copyright)
