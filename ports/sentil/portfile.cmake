set(SENTIL_VERSION 0.3.0)
set(SENTIL_RELEASE "https://github.com/sedislab/SENTIL/releases/download/v${SENTIL_VERSION}")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_TARGET_IS_LINUX)
    if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        message(FATAL_ERROR "sentil ships a prebuilt bundle for linux-x86_64 only.")
    endif()
    set(SENTIL_PLATFORM "linux-x86_64")
    set(SENTIL_SHA512 "42ad31693badb2cf1660dca250be3e6f490fbb6bf93e1d9ede0408db8c11e20d8e316445a74b6c318d6d5f3f85e237fa0405d629492056d954d566486788a0fa")
    set(SENTIL_SHARED "libsentil.so")
    set(SENTIL_STATIC "libsentil.a")
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(SENTIL_PLATFORM "macos-x86_64")
        set(SENTIL_SHA512 "2328dd5c1c31a3c5f355122723ccbb293c02010f58ac3019e11687191269e73cfa1fc747544e50ccdb22bf104f5ab0c38a01bc3456a30fc26532cc038daabb8b")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(SENTIL_PLATFORM "macos-arm64")
        set(SENTIL_SHA512 "464f1e56348e2fb25cc30dd70470ca8551810027e827c6c52d4bd94ea766616515d16e2efe5176e3eb6145a23d44f462b18780acf8456b3d376c373a8a8eeb87")
    else()
        message(FATAL_ERROR "sentil ships a prebuilt bundle for macos x86_64 and arm64 only.")
    endif()
    set(SENTIL_SHARED "libsentil.dylib")
    set(SENTIL_STATIC "libsentil.a")
elseif(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        message(FATAL_ERROR "sentil ships a prebuilt bundle for windows-x86_64 only.")
    endif()
    set(SENTIL_PLATFORM "windows-x86_64")
    set(SENTIL_SHA512 "f0e2ef0edd5793d53b4b405269e22e1b711f367febe35df0ea0b65ae56f76f41d7490ce6d8ffdcbf87c09ff9a253d497d985e2767eee5fc7562b635222475907")
    set(SENTIL_SHARED "sentil.dll")
    set(SENTIL_IMPORT_LIB "sentil.dll.lib")
else()
    message(FATAL_ERROR "sentil has no prebuilt bundle for this platform.")
endif()

set(SENTIL_BUNDLE "sentil-${SENTIL_VERSION}-${SENTIL_PLATFORM}")

vcpkg_download_distfile(SENTIL_ARCHIVE
    URLS "${SENTIL_RELEASE}/${SENTIL_BUNDLE}.tar.gz"
    FILENAME "${SENTIL_BUNDLE}.tar.gz"
    SHA512 "${SENTIL_SHA512}"
)

vcpkg_extract_source_archive(SENTIL_SRC
    ARCHIVE "${SENTIL_ARCHIVE}"
    SOURCE_BASE "${SENTIL_BUNDLE}"
)

file(INSTALL "${SENTIL_SRC}/include/sentil.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SENTIL_SRC}/include/sentil"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_SHARED}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_SHARED}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_IMPORT_LIB}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_IMPORT_LIB}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else()
    file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_SHARED}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_SHARED}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    if(EXISTS "${SENTIL_SRC}/lib/${SENTIL_STATIC}")
        file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_STATIC}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${SENTIL_SRC}/lib/${SENTIL_STATIC}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()

if(EXISTS "${SENTIL_SRC}/lib/pkgconfig/sentil.pc")
    file(READ "${SENTIL_SRC}/lib/pkgconfig/sentil.pc" SENTIL_PC)
    string(REGEX REPLACE "prefix=[^\n]*" "prefix=\${pcfiledir}/../.." SENTIL_PC_REL "${SENTIL_PC}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sentil.pc" "${SENTIL_PC_REL}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/sentil.pc" "${SENTIL_PC_REL}")
    vcpkg_fixup_pkgconfig()
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/SentilConfig.cmake"
"set(SENTIL_VERSION ${SENTIL_VERSION})

get_filename_component(SENTIL_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}/../..\" ABSOLUTE)
set(SENTIL_INCLUDE_DIR \"\${SENTIL_PREFIX}/include\")
set(SENTIL_LIBRARY \"\${SENTIL_PREFIX}/lib/\${CMAKE_SHARED_LIBRARY_PREFIX}sentil\${CMAKE_SHARED_LIBRARY_SUFFIX}\")

if(NOT TARGET Sentil::sentil)
    add_library(Sentil::sentil SHARED IMPORTED)
    set_target_properties(Sentil::sentil PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES \"\${SENTIL_INCLUDE_DIR}\")
    if(WIN32)
        set_target_properties(Sentil::sentil PROPERTIES
            IMPORTED_LOCATION \"\${SENTIL_PREFIX}/bin/sentil.dll\"
            IMPORTED_IMPLIB \"\${SENTIL_PREFIX}/lib/sentil.dll.lib\")
    else()
        set_target_properties(Sentil::sentil PROPERTIES
            IMPORTED_LOCATION \"\${SENTIL_LIBRARY}\")
    endif()
endif()
"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_download_distfile(SENTIL_LICENSE_MIT
    URLS "https://raw.githubusercontent.com/sedislab/SENTIL/v${SENTIL_VERSION}/LICENSE-MIT"
    FILENAME "sentil-${SENTIL_VERSION}-LICENSE-MIT"
    SHA512 "fca06c4f0b5d87bacb8180552cd78fcff29920cb8c916bc4407904cd61dcda956fc2a77225cc2df61a88048a29d4e5ba6e782a7f87070134dd318dadd92f5fd4"
)
vcpkg_download_distfile(SENTIL_LICENSE_APACHE
    URLS "https://raw.githubusercontent.com/sedislab/SENTIL/v${SENTIL_VERSION}/LICENSE-APACHE"
    FILENAME "sentil-${SENTIL_VERSION}-LICENSE-APACHE"
    SHA512 "1893a8f4251653e1b0a62983d0c1b049e0e178dc493d74bd035bccf0286be35d57db437a7c011eabe44ba166730f1801a8c761c9ab560651dd5f258a264dddd7"
)
vcpkg_install_copyright(FILE_LIST "${SENTIL_LICENSE_MIT}" "${SENTIL_LICENSE_APACHE}")