# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
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
    REPO vossg/OpenSG1x
    REF 5622fc72d574c38c044cd995d3272d16f3710c5f
    SHA512 b168bb2aac283f8d0daff02e1cf5647f982fcabf3be351ccf5776d476b5154baa3f128b3757c43996ebc7041c2a480e9559ad3d14e1abd8c7823358c12865e34
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${OPTIONS} -DOSGBUILD_OSGWindowQT4=OFF 
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/OpenSG RENAME copyright)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/debug/OSGWindowWIN32D.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OSGWindowWIN32D.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/debug/OSGWindowGLUTD.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OSGWindowGLUTD.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/debug/OSGSystemD.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OSGSystemD.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/debug/OSGBaseD.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OSGBaseD.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/osg2-config)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/debug/OSGWindowWIN32D.lib ${CURRENT_PACKAGES_DIR}/debug/lib/OSGWindowWIN32D.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/debug/OSGWindowGLUTD.lib ${CURRENT_PACKAGES_DIR}/debug/lib/OSGWindowGLUTD.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/debug/OSGSystemD.lib ${CURRENT_PACKAGES_DIR}/debug/lib/OSGSystemD.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/debug/OSGBaseD.lib ${CURRENT_PACKAGES_DIR}/debug/lib/OSGBaseD.lib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

file(RENAME ${CURRENT_PACKAGES_DIR}/bin/rel/OSGWindowWIN32.dll ${CURRENT_PACKAGES_DIR}/bin/OSGWindowWIN32.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/rel/OSGWindowGLUT.dll ${CURRENT_PACKAGES_DIR}/bin/OSGWindowGLUT.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/rel/OSGSystem.dll ${CURRENT_PACKAGES_DIR}/bin/OSGSystem.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/rel/OSGBase.dll ${CURRENT_PACKAGES_DIR}/bin/OSGBase.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/osg2-config)

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/rel/OSGWindowWIN32.lib ${CURRENT_PACKAGES_DIR}/lib/OSGWindowWIN32.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/rel/OSGWindowGLUT.lib ${CURRENT_PACKAGES_DIR}/lib/OSGWindowGLUT.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/rel/OSGSystem.lib ${CURRENT_PACKAGES_DIR}/lib/OSGSystem.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/rel/OSGBase.lib ${CURRENT_PACKAGES_DIR}/lib/OSGBase.lib)


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/rel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/rel)

vcpkg_copy_pdbs()
