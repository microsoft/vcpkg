vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Open-Cascade-SAS/OCCT
    REF V7_4_0
    SHA512 595ad7226b9365c1a7670b77001f71787a5d8aaa4a93a4a4d8eb938564670d79ae5a247ae7cc770b5da53c9a9f2e4166ba6e5ae104c1f2debad19ec2187f4a56
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(LIBRARY_TYPE "Shared")
else()
  set(LIBRARY_TYPE "Static")
endif()

# We turn off BUILD_MODULE_Draw as it requires TCL 8.6 and TK 8.6 specifically which conflicts with vcpkg only having TCL 9.0 
# And pre-built ActiveTCL binaries are behind a marketing wall :(
# We use the Unix install layout for Windows as matches vcpkg
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_LIBRARY_TYPE=${LIBRARY_TYPE}
		-DBUILD_MODULE_Draw=OFF
		-DINSTALL_DIR_LAYOUT=Unix
		-DBUILD_SAMPLES_MFC=OFF
		-DBUILD_SAMPLES_QT=OFF
		-DBUILD_DOC_Overview=OFF
)

vcpkg_install_cmake()

# debug creates libd and bind directories that need moving
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bind ${CURRENT_PACKAGES_DIR}/debug/bin)

# Remove libd to lib, libd just has cmake files we dont want too
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/libd ${CURRENT_PACKAGES_DIR}/debug/lib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# the bin directory ends up with bat files that are noise, let's clean that up
file(GLOB BATS ${CURRENT_PACKAGES_DIR}/bin/*.bat)
file(REMOVE_RECURSE ${BATS})

# move cmake files into the share folder
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)

file(INSTALL ${SOURCE_PATH}/OCCT_LGPL_EXCEPTION.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)