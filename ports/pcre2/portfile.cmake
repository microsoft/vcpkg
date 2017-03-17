include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pcre2-10.23)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/pcre/files/pcre2/10.23/pcre2-10.23.zip/download"
    FILENAME "pcre2-10.23.zip"
    SHA512 0f0638ce28ce17e18425d499cc516a30dabbfa868180ea320361ffeaa26d4f6f6975f12bc20024f7457fe3c6eed686976a9e5c66c2785d1ea63bee38131ea0d2)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPCRE2_BUILD_PCRE2_8=ON
        -DPCRE2_BUILD_PCRE2_16=ON
        -DPCRE2_BUILD_PCRE2_32=ON
        -DPCRE2_SUPPORT_JIT=ON
        -DPCRE2_SUPPORT_UNICODE=ON
        -DPCRE2_BUILD_TESTS=OFF
        -DPCRE2_BUILD_PCRE2GREP=OFF)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/pcre2.h PCRE2_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(PCRE2_STATIC)" "1" PCRE2_H "${PCRE2_H}")
else()
    string(REPLACE "defined(PCRE2_STATIC)" "0" PCRE2_H "${PCRE2_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/pcre2.h "${PCRE2_H}")

# don't install POSIX wrapper
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/pcre2posix.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/pcre2-posix.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pcre2-posixd.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/pcre2-posix.dll ${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-posixd.dll)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcre2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcre2/COPYING ${CURRENT_PACKAGES_DIR}/share/pcre2/copyright)
