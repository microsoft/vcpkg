vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Detect platform
if(VCPKG_TARGET_IS_WINDOWS)
    set(ORT_PLATFORM "win")
elseif(VCPKG_TARGET_IS_OSX)
    set(ORT_PLATFORM "osx")
elseif(VCPKG_TARGET_IS_LINUX)
    set(ORT_PLATFORM "linux")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# Detect variant
if(DEFINED VCPKG_ONNXRUNTIME_VARIANT)
    set(ORT_VARIANT "${VCPKG_ONNXRUNTIME_VARIANT}")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(ORT_FILE_EXT "zip")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        if("gpu" IN_LIST FEATURES)
            set(ORT_VARIANT "x64-gpu")
        else()
            set(ORT_VARIANT "x64")
        endif()
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ORT_VARIANT "arm64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ORT_VARIANT "x86")
    else()
        message(FATAL_ERROR "Unsupported Windows architecture")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    set(ORT_FILE_EXT "tgz")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ORT_VARIANT "arm64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ORT_VARIANT "x86_64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "universal2")
        set(ORT_VARIANT "universal2")
    else()
        message(FATAL_ERROR "Unsupported macOS architecture")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    set(ORT_FILE_EXT "tgz")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        if("gpu" IN_LIST FEATURES)
            set(ORT_VARIANT "x64-gpu")
        else()
            set(ORT_VARIANT "x64")
        endif()
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "aarch64")
        set(ORT_VARIANT "aarch64")
    else()
        message(FATAL_ERROR "Unsupported Linux architecture")
    endif()
else()
    message(FATAL_ERROR "Unsupported platform/architecture combination")
endif()

set(ORT_ARCHIVE "onnxruntime-${ORT_PLATFORM}-${ORT_VARIANT}-${VERSION}.${ORT_FILE_EXT}")
set(ORT_DIR "onnxruntime-${ORT_PLATFORM}-${ORT_VARIANT}-${VERSION}")

# Set SHA512 for each platform/variant
if(VCPKG_TARGET_IS_WINDOWS AND ORT_VARIANT STREQUAL "x64")
    set(ORT_SHA512 "afe7d01e20776a0509761d1111ce49744b5768d97e891e5753fdaaf2b1ee05ca6526dc2ef34b57fbd23b1dc84f7db79fc8fd2e3005739c186d88c32b4d8606b9")
elseif(VCPKG_TARGET_IS_WINDOWS AND ORT_VARIANT STREQUAL "x64-gpu")
    set(ORT_SHA512 "6b3ad68fa6deda184143f2ed41e041fda949f72a99c2c083e363e47d036870a63092dfb345352b8aa8419538279e71d1b459fe1c942a7b47f3d9dc21070024e5")
elseif(VCPKG_TARGET_IS_WINDOWS AND ORT_VARIANT STREQUAL "x86")
    set(ORT_SHA512 "399806093d36dc37c087f43c7b33a5767ae01496994f015d43d0fbfddeabcc2c006f6fc4bade554845a5136092f4db8ae3e64677c65f36ebccc0fb8f7388fe7a")
elseif(VCPKG_TARGET_IS_WINDOWS AND ORT_VARIANT STREQUAL "arm64")
    set(ORT_SHA512 "fee77bd8ff60792a22132229bbda3b4dc5a53fadac16d3f3e525fd4b02412e874dd49358f50db871e3816943300f387a852bb66dc268f0e67d2ea09ea0874d30")
elseif(VCPKG_TARGET_IS_OSX AND ORT_VARIANT STREQUAL "arm64")
    set(ORT_SHA512 "71e3c6f82913ec93f506145f71db223c574ca0d84ddc84270d1d7a854018fe2e1044ce212ad7d6873c60e15a26e462ce84477500d7ba9af05c442e607e226b8e")
elseif(VCPKG_TARGET_IS_OSX AND ORT_VARIANT STREQUAL "x86_64")
    set(ORT_SHA512 "9cb66217494153266417fbfca447cef9ee72a0f575675150e761bf4ac25e64b0aaba31f1fd40449c5aa3a0617dcd89c81dc2745a0dccde233d63451e8b769528")
elseif(VCPKG_TARGET_IS_OSX AND ORT_VARIANT STREQUAL "universal2")
    set(ORT_SHA512 "d05f8e310314233b90f4da76758fcdcf36efbfb2a83e66475c920eebf335e7fc84354a8ef7ab3394596e2bfa659844597b55626d51ee52e1547ad3f941b9a0b9")
elseif(VCPKG_TARGET_IS_LINUX AND ORT_VARIANT STREQUAL "x64")
    set(ORT_SHA512 "c49d927a39dc27fcdf3b41436806af74c24c79ead09289d986c359fc1380ea363cf83d4085212b8972cb752a0fa8b9b1a06b82ad19e2d4dd6e22e44c79050386")
elseif(VCPKG_TARGET_IS_LINUX AND ORT_VARIANT STREQUAL "x64-gpu")
    set(ORT_SHA512 "74b0138f8a851dc05490ade451e92880e7a16cd6ae87cb233b8f160e50906d9a95c1fecf30d502bbe4d9e7c2fc335b4079eebcfa669532ebb41564fd3f81c142")
elseif(VCPKG_TARGET_IS_LINUX AND ORT_VARIANT STREQUAL "aarch64")
    set(ORT_SHA512 "a78f60d1c641e27eafe92a292c7c3d5334fb94d9e05a8e0187c1a84d4a2a2a0008fe88b9040e0c19afcf3f174af92fb4908b74e798711483e3372c1bf07375f5")
else()
    message(FATAL_ERROR "No SHA512 defined for this platform/variant combination")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v${VERSION}/${ORT_ARCHIVE}"
    FILENAME "${ORT_ARCHIVE}"
    SHA512 "${ORT_SHA512}" # Update for each variant
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

# Download repo for experimental features
vcpkg_from_github(
    OUT_SOURCE_PATH REPO_PATH
    REPO microsoft/onnxruntime
    REF v${VERSION}
    SHA512 32310215a3646c64ff5e0a309c3049dbe02ae9dd5bda8c89796bd9f86374d0f43443aed756b941d9af20ef1758bb465981ac517bbe8ac33661a292d81c59b152
)

file(COPY
    ${REPO_PATH}/include/onnxruntime/core/session/experimental_onnxruntime_cxx_api.h 
    ${REPO_PATH}/include/onnxruntime/core/session/experimental_onnxruntime_cxx_inline.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/lib
    ${CURRENT_PACKAGES_DIR}/debug/bin
)

file(COPY
    ${SOURCE_PATH}/${ORT_DIR}/include
    DESTINATION ${CURRENT_PACKAGES_DIR}
)

# Copy all relevant library files
if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB ORT_LIBS "${SOURCE_PATH}/${ORT_DIR}/lib/*.lib")
    file(GLOB ORT_DLLS "${SOURCE_PATH}/${ORT_DIR}/lib/*.dll")
    file(GLOB ORT_PDBS "${SOURCE_PATH}/${ORT_DIR}/lib/*.pdb")
    file(COPY ${ORT_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${ORT_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${ORT_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${ORT_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${ORT_PDBS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${ORT_PDBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB ORT_LIBS "${SOURCE_PATH}/${ORT_DIR}/lib/*")
    file(COPY ${ORT_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${ORT_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/${ORT_DIR}/LICENSE")
