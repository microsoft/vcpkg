include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SHA 21998464c84ddaa9f911d8d05378d6f23a3a3671)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SHA})

vcpkg_download_distfile(HEADERFILE
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${SHA}/tree/tinyfiledialogs.h?format=raw"
    FILENAME "tinyfiledialogs-h-${SHA}"
    SHA512 3f15192e2e2ba674308330eca88f5f2430980b93a53389125fab4de0fce775b9a0e2a0464a3a69bd86e362715c866504e752bfea402f1072005f6da3c97316d8
)
vcpkg_download_distfile(SOURCEFILE
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${SHA}/tree/tinyfiledialogs.c?format=raw"
    FILENAME "tinyfiledialogs-c-${SHA}"
    SHA512 b03260ba84872b3cf4eae2fed3a1770480021e3d4109f5ef243a433da48e443b7f244b105a16ce9d5655e086774d9098628e56b1559a6862fb5add547210ca58
)

configure_file(${HEADERFILE} ${SOURCE_PATH}/tinyfiledialogs.h COPYONLY)
configure_file(${SOURCEFILE} ${SOURCE_PATH}/tinyfiledialogs.c COPYONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${HEADERFILE} _contents)
string(SUBSTRING "${_contents}" 0 1024 _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tinyfiledialogs/copyright "${_contents}")
