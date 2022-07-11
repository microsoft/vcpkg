
# For ports which are not CMake
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/${PORT}.pdb" AND 
       EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}.pdb")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}_strip.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/bin")
endif()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${PORT}.pdb" AND 
       EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}.pdb")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL 
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}_strip.pdb" 
            DESTINATION
                "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()