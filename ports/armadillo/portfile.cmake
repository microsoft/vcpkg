include(vcpkg_common_functions)

#as conradsnicta/armadillo-code has no release, and the link http://sourceforge.net/projects/arma/files/armadillo-8.400.0.tar.xz is not worked, I use the latest commit for 8.400.x branch
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO conradsnicta/armadillo-code
    REF a25f66da4c27d40a4a7699199cbf4dc747e712a7
    SHA512 bf5e1de18c38503e46f72f4f9f145477b6b782baf0df42600acb8811c7a07a5d8c0cd2ac3015d4169c961876e4cbb0457a7c1417b55ba52c98d4f78d145f9ae6
    HEAD_REF refs/remotes/origin/8.400.x
)


#TODO -DDETECT_HDF5=false or build will fail, need dig why
#TODO ninja build is not work, need dig why
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DDETECT_HDF5=false
    OPTIONS_DEBUG    
        -DDETECT_HDF5=false
)


vcpkg_install_cmake()

vcpkg_copy_pdbs()

#armadillo.dll from ${PROJECT_SOURCE_DIR}/src/wrapper.cpp should be deleted, it's meaningless for windows，your should link to related lib directly
#for vcpkg user, you should just install one implementation if you enable vcpkg integration, as the the system will link to all the installed lib, which will cause conflict
#BTW, dll has no lib is not allow by vcpkg, maybe a patch for upstream will fix it?
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin) 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt  DESTINATION ${CURRENT_PACKAGES_DIR}/share/armadillo RENAME copyright)