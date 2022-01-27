vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/akali
    REF 57fea619dea42aa116679b22340f56fc94eb83a9
    SHA512 b80f7e72396032e8b24464e159f4a6c24663d671bcbe9ffa46f68e5bc0398fd0caf3ac918f8ccb8d304be4d5a3fade2821f87f7270e02ec8aae722e2faeab0f3
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AKALI_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DAKALI_STATIC:BOOL=${AKALI_STATIC}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/akali)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/akali)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h AKALI_EXPORT_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "#ifdef AKALI_STATIC" "#if 1" AKALI_EXPORT_H "${AKALI_EXPORT_H}")
else()
    string(REPLACE "#ifdef AKALI_STATIC" "#if 0" AKALI_EXPORT_H "${AKALI_EXPORT_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h "${AKALI_EXPORT_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
