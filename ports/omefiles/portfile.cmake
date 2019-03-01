include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("omefiles only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/omefiles-0.1.0)
file(REMOVE_RECURSE ${SOURCE_PATH}/ome-common ${SOURCE_PATH}/ome-model ${SOURCE_PATH}/ome-files ${SOURCE_PATH}/CMakeLists.txt)

set(OME_COMMON_REF e9c630f7e9615ba7b0044bd1237d1ee3dd39ebb8)
set(OME_MODEL_REF 3dfdd63a12f0c2dbe3b89d7f5fbd2f90acf3ac47)
set(OME_FILES_REF 6a74d4f9a3595de7c0f450b33117b82bb949e636)

vcpkg_download_distfile(OME_COMMON
    URLS https://gitlab.com/codelibre/ome-common-cpp/-/archive/${OME_COMMON_REF}/ome-common-cpp-${OME_COMMON_REF}.tar.gz
    FILENAME "ome-common.tar.gz"
    SHA512 84a13c29fac6c8600b0c2d9f900129f6514b75c406a478ca20742198ed06870160c067fa3dfdfac19091a1830971565be9dda2cfcefabbc24980a30fadc1044e
)

vcpkg_download_distfile(OME_MODEL
    URLS https://gitlab.com/codelibre/ome-model/-/archive/${OME_MODEL_REF}/ome-model-${OME_MODEL_REF}.tar.gz
    FILENAME "ome-model.tar.gz"
    SHA512 060ffd73120363df85d836d334044c042f86b2a6d683358f96a23d4e45c1bac0293fba05b1d958fc990dc0f1421cacb658a79e5f032644895003065697a0ce01
)


vcpkg_download_distfile(OME_FILES
    URLS https://gitlab.com/codelibre/ome-files-cpp/-/archive/${OME_FILES_REF}/ome-files-cpp-${OME_FILES_REF}.tar.gz
    FILENAME "ome-files.tar.gz"
    SHA512 b986afa608d057a2790945875144ef3528c328c870938b12dccce3f8a1cca89d072f162ba436f39b7406b4d2cb898e4db11b914a5f697a7a0d1a5c412c0bc290
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH OME_COMMON_SOURCE
    ARCHIVE ${OME_COMMON}
    REF ome-common
    PATCHES
        variant.patch
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH OME_MODEL_SOURCE
    ARCHIVE ${OME_MODEL}
    REF ome-model
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH OME_FILES_SOURCE
    ARCHIVE ${OME_FILES}
    REF ome-files
)

file(REMOVE_RECURSE ${SOURCE_PATH})
file(MAKE_DIRECTORY ${SOURCE_PATH})

file(RENAME ${OME_COMMON_SOURCE} ${SOURCE_PATH}/ome-common)
file(RENAME ${OME_MODEL_SOURCE} ${SOURCE_PATH}/ome-model)
file(RENAME ${OME_FILES_SOURCE} ${SOURCE_PATH}/ome-files)

set(CMAKELIST_FOLDERS 
    ome-common/lib/ome/common
    ome-common/lib/ome/compat
    ome-common/lib/ome/unit-types
    ome-common/lib/ome/xalan-util
    ome-common/lib/ome/xerces-util
    ome-model/ome-xml/src/main/cpp/ome/xml
    ome-files/lib/ome/files)

# Install config files in share folder across platforms
foreach(CMAKELIST IN LISTS CMAKELIST_FOLDERS)
    set(CMAKELIST ${SOURCE_PATH}/${CMAKELIST}/CMakeLists.txt)
    file(READ ${CMAKELIST} _contents)
    string(REGEX REPLACE  
         "if\\(WIN32\\)\n  set\\(([a-zA-Z_]+) \"cmake\"\\)\nelse\\(\\)\n  set\\(([a-zA-Z_]+) \"\\$\\{CMAKE_INSTALL_LIBDIR\\}/cmake/[a-zA-Z_]+\"\\)\nendif\\(\\)" 
         "set(\\1 \"\${CMAKE_INSTALL_DATAROOTDIR}/OMEFiles\")"
        _contents "${_contents}")
    message("Patching: ${CMAKELIST}")
    file(WRITE ${CMAKELIST} "${_contents}")
endforeach()

set(BOOST_CMAKE_FILES 
    ome-common/cmake/BoostChecks.cmake
    ome-common/cmake/FilesystemChecks.cmake
    ome-common/CMakeLists.txt
    ome-files/cmake/BoostChecks.cmake
    ome-model/CMakeLists.txt
    ome-model/cmake/BoostChecks.cmake
    ome-model/CMakeLists.txt)

# Install config files in share folder across platforms
foreach(BOOST_CMAKE_FILE IN LISTS BOOST_CMAKE_FILES)
    message("Patching: ${SOURCE_PATH}/${BOOST_CMAKE_FILE}")
    file(READ ${SOURCE_PATH}/${BOOST_CMAKE_FILE} _contents)
    string(REPLACE  
         "set(CMAKE_REQUIRED_DEFINITIONS \$\{CMAKE_REQUIRED_DEFINITIONS\} -DBOOST_ALL_DYN_LINK -DBOOST_ALL_NO_LIB)" ""
        _contents "${_contents}")   
    string(REPLACE  
         "set(Boost_USE_STATIC_LIBS OFF)" ""
        _contents "${_contents}")
    string(REPLACE
        "add_definitions(-DBOOST_ALL_DYN_LINK -DBOOST_ALL_NO_LIB)" ""
        _contents "${_contents}")
    string(REPLACE
        "set(CMAKE_REQUIRED_LIBRARIES \$\{CMAKE_REQUIRED_LIBRARIES\} \$\{Boost_FILESYSTEM_LIBRARY_RELEASE\} \$\{Boost_SYSTEM_LIBRARY_RELEASE\})" 
        "set(CMAKE_REQUIRED_LIBRARIES \$\{CMAKE_REQUIRED_LIBRARIES\} Boost::filesystem Boost::system)"
        _contents "${_contents}")
    file(WRITE ${SOURCE_PATH}/${BOOST_CMAKE_FILE} "${_contents}")
endforeach()

set(LOG_FILE ${SOURCE_PATH}/ome-common/lib/ome/common/log.h)
file(READ ${LOG_FILE} _contents)
string(REPLACE  
       "#define BOOST_LOG_DYN_LINK" ""
       _contents "${_contents}")
file(WRITE ${LOG_FILE} "${_contents}")

file(REMOVE ${SOURCE_PATH}/ome-files/cmake/FindTIFF.cmake)


vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}  
    PATCHES cmakelists.patch
)

vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
       -Dtest:BOOL=OFF
       -Dextended-tests:BOOL=OFF
       -Drelocatable-install:BOOL=ON
       -Dsphinx:BOOL=OFF
       -DCMAKE_CXX_STANDARD=14
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/OMEFiles TARGET_PATH share/OMEFiles)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(COPY ${SOURCE_PATH}/ome-files/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/OMEFiles)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/OMEFiles/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/OMEFiles/copyright)