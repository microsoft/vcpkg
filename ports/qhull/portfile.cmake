# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
    REPO qhull/qhull
	REF  master
    SHA512 16aa9f93ce6fe8342a3b579881f10bb417679b0a70849e6b0cc5a89551e4de773a43bb0d54948196690d68d168f3a2a215e4600745ff1566302b0b426565fb25	
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
     #PREFER_NINJA # Disable this option if project cannot be built with Ninja
     OPTIONS 
	-DINCLUDE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/include
    -DMAN_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
	-DDOC_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
	 
	 OPTIONS_RELEASE
    -Dqhull_TARGETS_INSTALL=qhullcpp	 
	-DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib
     
	 OPTIONS_DEBUG	 
	-Dqhull_TARGETS_INSTALL=qhullcpp_d	  	 
	-DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib	 
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB_RECURSE HTMFILES ${CURRENT_PACKAGES_DIR}/include/*.htm)
file(REMOVE ${HTMFILES})

# Handle copyright
file(COPY ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/qhull)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qhull/README.txt ${CURRENT_PACKAGES_DIR}/share/qhull/copyright)
