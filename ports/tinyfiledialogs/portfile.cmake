include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SHA 03d35a86696859128d41f8b967c1ef3e39c980ce)

vcpkg_download_distfile(HEADERFILE
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${SHA}/tree/tinyfiledialogs.h?format=raw"
    FILENAME "tinyfiledialogs-h-${SHA}"
    SHA512 e3503165bcbb665c2f09c19591f28eba63e50b8d20fd4e65f31ec6a33742879c007aa7402cfd429ff92a2847534f0f0cc1b979954372be0c6578d49ed5f3e18d
)
vcpkg_download_distfile(SOURCEFILE
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${SHA}/tree/tinyfiledialogs.c?format=raw"
    FILENAME "tinyfiledialogs-c-${SHA}"
    SHA512 263a9fcd11af3dcfd3cd7b6cfaad216cfdd94925639e613d43e7a2dbae2b4387fe8182cd72401e19b2891a08809bc68caece341df28e91b5894cc4b9ecd157f4
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SHA})

configure_file(${HEADERFILE} ${SOURCE_PATH}/tinyfiledialogs.h COPYONLY)
configure_file(${SOURCEFILE} ${SOURCE_PATH}/tinyfiledialogs.c COPYONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

configure_file(${HEADERFILE} ${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs.h COPYONLY)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/tinyfiledialogs)
file(READ ${HEADERFILE} _contents)
string(SUBSTRING "${_contents}" 0 1024 _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tinyfiledialogs/copyright "${_contents}")
