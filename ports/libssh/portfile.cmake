include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "WindowsStore not supported")
endif()
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libssh-0.7.5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libssh.org/files/0.7/libssh-0.7.5.tar.xz"
    FILENAME "libssh-0.7.5.tar.xz"
    SHA512 6c7f539899caaedf13d66fa2e0fac1a475ecdfe389131abcbdf908bdebc50a0b9e6b0d43e67e52aea85c32f6aa68e46ca2f50695992f82ded83489f445a8e775
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
