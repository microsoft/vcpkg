include(vcpkg_common_functions)
set(UNRAR_VERSION "5.5.8")
set(UNRAR_SHA512 9eac83707fa47a03925e5f3e8adf47889064d748304b732d12a2d379ab525b441f1aa33216377d4ef445f45c4e8ad73d2cd0b560601ceac344c60571b77fd6aa)
set(UNRAR_FILENAME unrarsrc-${UNRAR_VERSION}.tar.gz)
set(UNRAR_URL http://www.rarlab.com/rar/${UNRAR_FILENAME})
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/unrar)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

#SRC
vcpkg_download_distfile(ARCHIVE
    URLS ${UNRAR_URL}
    FILENAME ${UNRAR_FILENAME}
    SHA512 ${UNRAR_SHA512}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/UnRARDll.vcxproj"
    OPTIONS_DEBUG /p:OutDir=../../${TARGET_TRIPLET}-dbg/
    OPTIONS_RELEASE /p:OutDir=../../${TARGET_TRIPLET}-rel/
    OPTIONS /VERBOSITY:Diagnostic /DETAILEDSUMMARY
)

#INCLUDE (named dll.hpp in source, and unrar.h in all rarlabs distributions)
file(INSTALL ${SOURCE_PATH}/dll.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME unrar.h)

#DLL & LIB
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/unrar.dll  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/unrar.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/unrar.dll  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/unrar.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

#COPYRIGHT
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/unrar RENAME copyright)
