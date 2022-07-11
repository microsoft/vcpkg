
set(install_subdir "bin")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(install_subdir "lib")
endif()

# For ports which are not CMake
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/${install_subdir}/${PORT}.pdb" AND 
       EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}.pdb")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/${install_subdir}")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}_strip.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/${install_subdir}")
endif()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/debug/${install_subdir}/${PORT}.pdb" AND 
       EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}.pdb")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/debug/${install_subdir}")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}_strip.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/debug/${install_subdir}")
endif()