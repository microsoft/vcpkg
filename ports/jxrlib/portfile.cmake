include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download-codeplex.sec.s-msft.com/Download/SourceControlFileDownload.ashx?ProjectName=jxrlib&changeSetId=e922fa50cdf9a58f40cad07553bcaa2883d3c5bf"
    FILENAME "jxrlib_1_1.zip"
    SHA512 c4f42c690a2543b00ef9fe6e4f479b582e966b27c13e8b0efad39fa85d70b4edb60eac91a856c371a4e875e7a2769e0aba31b508ee61f7314150c6eb34a19c0b
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# The file guiddef.h is part of the Windows SDK,
# we then remove the local copy shipped with jxrlib
file(REMOVE ${SOURCE_PATH}/common/include/guiddef.h)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jxrlib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jxrlib/LICENSE ${CURRENT_PACKAGES_DIR}/share/jxrlib/copyright)

vcpkg_copy_pdbs()
