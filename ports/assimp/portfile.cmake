vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO assimp/assimp
    REF 8f0c6b04b2257a520aaab38421b2e090204b69df # v5.0.1
    SHA512 59b213428e2f7494cb5da423e6b2d51556318f948b00cea420090d74d4f5f0f8970d38dba70cd47b2ef35a1f57f9e15df8597411b6cd8732b233395080147c0f
    HEAD_REF master
    PATCHES
        build_fixes.patch
        irrlicht.patch
)

file(REMOVE ${SOURCE_PATH}/cmake-modules/FindZLIB.cmake)
file(REMOVE ${SOURCE_PATH}/cmake-modules/FindIrrXML.cmake)
#file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/clipper) # https://github.com/assimp/assimp/issues/788
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/poly2tri)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/zlib)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/gtest)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/irrXML)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/rapidjson)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/stb_image)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/zip)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/unzip)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/utf8cpp)
#file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/Open3DGC)      #TODO
#file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/openddlparser) #TODO

set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ASSIMP_BUILD_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DASSIMP_BUILD_TESTS=OFF
            -DASSIMP_BUILD_ASSIMP_VIEW=OFF
            -DASSIMP_BUILD_ZLIB=OFF
            -DASSIMP_BUILD_SHARED_LIBS=${ASSIMP_BUILD_SHARED_LIBS}
            -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
            -DASSIMP_INSTALL_PDB=OFF
            -DSYSTEM_IRRXML=ON
            -DIGNORE_GIT_HASH=ON
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCVER vc140 vc141 vc142 )
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/assimp.pc" "-lassimp" "-l${ASSIMP_NAME_REL}")
endif()
if(ASSIMP_DBG)
    get_filename_component(ASSIMP_NAME_DBG "${ASSIMP_DBG}" NAME_WLE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/assimp.pc" "-lassimp" "-l${ASSIMP_NAME_DBG}")
endif()

vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig() # Probably requires more fixing for static builds. See qt5-3d and the config changes below
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/share/assimp/assimpConfig.cmake ASSIMP_CONFIG)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/assimp/assimpConfig.cmake "
include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(irrlicht CONFIG)
find_dependency(polyclipping CONFIG)
find_dependency(minizip CONFIG)
find_dependency(kubazip CONFIG)
find_dependency(poly2tri CONFIG)
find_dependency(utf8cpp CONFIG)
${ASSIMP_CONFIG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
