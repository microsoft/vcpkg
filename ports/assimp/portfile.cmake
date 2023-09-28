vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO assimp/assimp
    REF v${VERSION}
    SHA512 49963f84ed0a8145f3af249890a533f0b12f5553ae09581289cb1f20cb49cb1a3ed3f3c4c966ceb43aa897b90deca268aa6554066b2bd34f2ac9c15041420ddb
    HEAD_REF master
    PATCHES
        build_fixes.patch
)

file(REMOVE "${SOURCE_PATH}/cmake-modules/FindZLIB.cmake")

file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/clipper")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/draco")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/gtest")
#file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/Open3DGC")      #TODO
#file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/openddlparser") #TODO
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/poly2tri")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/pugixml")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/rapidjson")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/stb")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/unzip")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/utf8cpp")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/zip")
file(REMOVE_RECURSE "${SOURCE_PATH}/contrib/zlib")

set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DASSIMP_BUILD_ZLIB=OFF
        -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
        -DASSIMP_BUILD_TESTS=OFF
        -DASSIMP_WARNINGS_AS_ERRORS=OFF
        -DASSIMP_IGNORE_GIT_HASH=ON
        -DASSIMP_INSTALL_PDB=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/assimp")

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCVER vc140 vc141 vc142 vc143)
    set(CRT mt md)
    set(DBG_NAMES)
    set(REL_NAMES)
    foreach(_ver IN LISTS VCVER)
        foreach(_crt IN LISTS CRT)
            list(APPEND DBG_NAMES assimp-${_ver}-${_crt}d)
            list(APPEND REL_NAMES assimp-${_ver}-${_crt})
        endforeach()
    endforeach()
endif()

find_library(ASSIMP_REL NAMES assimp ${REL_NAMES} PATHS "${CURRENT_PACKAGES_DIR}/lib" NO_DEFAULT_PATH)
find_library(ASSIMP_DBG NAMES assimp assimpd ${DBG_NAMES} PATHS "${CURRENT_PACKAGES_DIR}/debug/lib" NO_DEFAULT_PATH)
if(ASSIMP_REL)
    get_filename_component(ASSIMP_NAME_REL "${ASSIMP_REL}" NAME_WLE)
    string(REGEX REPLACE "^lib(.*)" "\\1" ASSIMP_NAME_REL "${ASSIMP_NAME_REL}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/assimp.pc" "-lassimp" "-l${ASSIMP_NAME_REL}")
endif()
if(ASSIMP_DBG)
    get_filename_component(ASSIMP_NAME_DBG "${ASSIMP_DBG}" NAME_WLE)
    string(REGEX REPLACE "^lib(.*)" "\\1" ASSIMP_NAME_DBG "${ASSIMP_NAME_DBG}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/assimp.pc" "-lassimp" "-l${ASSIMP_NAME_DBG}")
endif()

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    set(assimp_PC_REQUIRES "draco polyclipping pugixml minizip")
    set(assimp_LIBS_REQUIRES "-lpoly2tri")

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/assimp.pc" "Libs:" "Requires.private: ${assimp_PC_REQUIRES}\nLibs:")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/assimp.pc" "Libs.private:" "Libs.private: ${assimp_LIBS_REQUIRES}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/assimp.pc" "Libs:" "Requires.private: ${assimp_PC_REQUIRES}\nLibs:")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/assimp.pc" "Libs.private:" "Libs.private: ${assimp_LIBS_REQUIRES}")
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
