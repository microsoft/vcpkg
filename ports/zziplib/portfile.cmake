vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF 24a6c6de1956189bffcd8dffd2ef3197c6f3df29 # v0.13.71
    SHA512 246ee1d93f3f8a6889e9ab362e04e6814813844f2cdea0a782910bf07ca55ecd6d8b1c456b4180935464cebf291e7849af27ac0ed5cc080de5fb158f9f3aeffb
    PATCHES
        install-dll-to-proper-folder.patch
        no-release-postfix.patch
        fix-export-define.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(MSVC_STATIC_RUNTIME ON)
else()
    set(MSVC_STATIC_RUNTIME OFF)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC_LIBS ON)
else()
    set(BUILD_STATIC_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DMSVC_STATIC_RUNTIME=${MSVC_STATIC_RUNTIME}
        -DZZIPMMAPPED=OFF
        -DZZIPFSEEKO=OFF
        -DZZIPWRAP=OFF
        -DZZIPSDL=OFF
        -DZZIPBINS=OFF
        -DZZIPTEST=OFF
        -DZZIPDOCS=OFF
        -DZZIPCOMPAT=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/zziplib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zziplib/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/zziplib/copyright)
