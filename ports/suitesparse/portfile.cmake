include(vcpkg_common_functions)

set(SUITESPARSE_VER SuiteSparse-4.5.4)
set(METIS_VER metis-5.1.0)
set(SUITESPARSEWIN_PATH ${CURRENT_BUILDTREES_DIR}/src/suitesparse-metis-for-windows-1.3.1)
set(SUITESPARSE_PATH ${SUITESPARSEWIN_PATH}/Suitesparse)
set(METIS_PATH ${SUITESPARSEWIN_PATH}/metis)



vcpkg_download_distfile(SUITESPARSEWIN
URLS  "https://github.com/jlblancoc/suitesparse-metis-for-windows/archive/v1.3.1.zip"
FILENAME "suitesparse-metis-for-windows-1.3.1.zip"
SHA512 f8b9377420432f1c0a05bf884fe9e72f1f4eaf7e05663c66a383b5d8ddbd4fbfaa7d433727b4dc3e66b41dbb96b1327d380b68a51a424276465512666e63393d
)
vcpkg_download_distfile(SUITESPARSE
    URLS "http://faculty.cse.tamu.edu/davis/SuiteSparse/${SUITESPARSE_VER}.tar.gz"
    FILENAME "${SUITESPARSE_VER}.tar.gz"
    SHA512 43d791065a69b8842acc3490fc8e2c24d32217864228cfc5106ece581f8867eb84cf9d7c03e01307366cb285c98dee37de13f8bbaf30466feeb56afed9002b9f
)
vcpkg_download_distfile(METIS
    URLS "http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/${METIS_VER}.tar.gz"
    FILENAME "${METIS_VER}.tar.gz"
    SHA512 deea47749d13bd06fbeaf98a53c6c0b61603ddc17a43dae81d72c8015576f6495fd83c11b0ef68d024879ed5415c14ebdbd87ce49c181bdac680573bea8bdb25
)

vcpkg_extract_source_archive(${SUITESPARSEWIN})

#extract suitesparse and copy into suitesparse folder in suitesparse-metis-for-windows package
vcpkg_extract_source_archive(${SUITESPARSE} ${SUITESPARSEWIN_PATH})

#extract metis and copy into metis folder in suitesparse-metis-for-windows package
vcpkg_extract_source_archive(${METIS})
file(COPY ${CURRENT_BUILDTREES_DIR}/src/${METIS_VER} DESTINATION ${METIS_PATH})
vcpkg_apply_patches(
    SOURCE_PATH ${METIS_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/metis.patch"           
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
    OPTIONS   
    OPTIONS_DEBUG   
)
vcpkg_install_cmake()