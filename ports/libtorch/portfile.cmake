include(vcpkg_common_functions)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda     USE_CUDA
)
if(${FEATURE_OPTIONS} MATCHES "USE_CUDA=ON")
    message(STATUS "Feature: CUDA")
    set(DEVICE "cu100")
else()
    message(STATUS "Feature: CPU")
    set(DEVICE "cpu")
endif()

# Download packages
if(WIN32)
    if(${DEVICE} STREQUAL "cu100")
        vcpkg_download_distfile(PYTORCH_DOWNLOAD_PATH
            URLS        https://download.pytorch.org/libtorch/${DEVICE}/libtorch-win-shared-with-deps-1.2.0.zip
            FILENAME    pytorch-gpu-release.zip
            SHA512      57d65cafa9179e6e43aa8c8e689f6e065c88f7920e5957b3641dcb4e5602e89b3519db5ca832e2f364c951ddcd7ee8f64113b43a45988205ca6ca62a3b9f5aa8
        )
        vcpkg_download_distfile(PYTORCH_DOWNLOAD_DEBUG_PATH
            URLS        https://download.pytorch.org/libtorch/${DEVICE}/libtorch-win-shared-with-deps-debug-1.2.0.zip
            FILENAME    pytorch-gpu-debug.zip
            SHA512      8d4593f3e08dd8b1c8c384062a1189981b84588cac375f85ce8f97a8962cd41eee7aa2a2868fb1a5b553c12f13f4c0146ce44fc173043483ccac9db194fc9415
        )
    else() # cpu
        vcpkg_download_distfile(PYTORCH_DOWNLOAD_PATH
            URLS        https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-1.2.0.zip
            FILENAME    pytorch-release.zip
            SHA512      9b626dab5ed95f71885e354aed899feceaf225c8f2af72aa6e5e4624ffe73693d3d86fdeb0447af38f884919e369633b383723cd4fd1d8fbe5f4116ef88a5472
        )
        vcpkg_download_distfile(PYTORCH_DOWNLOAD_DEBUG_PATH
            URLS        https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-debug-1.2.0.zip
            FILENAME    pytorch-debug.zip
            SHA512      dab7eb897444ce37aba49e061ad833afeacb329728c07e72afb9fbaf6611c7342d2fce92a4eb17df0ecbbeeb37dc7ab9f7f9ae752ab0e3df431a4ef5f01cc9ee
        )
    endif()
elseif(${VCPKG_CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    message(WARNING "MacOS binaries do not support CUDA")
    vcpkg_download_distfile(PYTORCH_DOWNLOAD_PATH
        URLS        https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.2.0.zip
        FILENAME    pytorch-release.zip
        SHA512      37996ce331a72dad92dee115b76c14e98e4b8bf99875aaf8261c03ded7126c39ac310897aec35bb93569eb710f70f4a25f5f4af1e17304e45ce71f2e04da41ea
    )
elseif(${VCPKG_CMAKE_SYSTEM_NAME} MATCHES "Linux")
    message(WARNING "Using cxx11 ABI")
    if(${DEVICE} STREQUAL "cu100")
        vcpkg_download_distfile(PYTORCH_DOWNLOAD_PATH
            URLS        https://download.pytorch.org/libtorch/${DEVICE}/libtorch-cxx11-abi-shared-with-deps-1.2.0.zip
            FILENAME    pytorch-gpu-release.zip
            SHA512      a62c15b44c7e160f22b9d059b015c8ffbe7debebb3a6efc8094d1ee22c9eb784394f65c8feaf33e538255e95ab4f8a9b23bba7996039faba0334f42e0a17a2fe
        )
    else() # cpu
        vcpkg_download_distfile(PYTORCH_DOWNLOAD_PATH
            URLS        https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.2.0.zip
            FILENAME    pytorch-release.zip
            SHA512      3a7833cf19fb80f5bfe195d4846301cf7dc55509d307b65eeaf296164bc870cd5e8886cc4772808500b21cfe5918b4abd88da70b35205eb7800edc3a8bd4fb5b
        )
    endif()
endif()

# Extraction
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH     SOURCE_PATH
    ARCHIVE             ${PYTORCH_DOWNLOAD_PATH}
)
if(DEFINED PYTORCH_DOWNLOAD_DEBUG_PATH)
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH     DEBUG_SOURCE_PATH
        ARCHIVE             ${PYTORCH_DOWNLOAD_DEBUG_PATH}
    )
endif()

# Header and Configurations
# INSTALL makes too long reporting. use COPY instead
file(COPY       ${SOURCE_PATH}/include
                ${SOURCE_PATH}/share
                # ${SOURCE_PATH}/cmake # protobuf already installed through vcpkg
    DESTINATION ${CURRENT_PACKAGES_DIR}
)

if(WIN32)
    # .exe
    file(GLOB  PYTORCH_EXECUTABLES
        "${SOURCE_PATH}/bin/*.exe"
        "${SOURCE_PATH}/test/*.exe"
    )
    file(COPY       ${PYTORCH_EXECUTABLES}
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools
    )

    # .dll
    file(GLOB  PYTORCH_DLL_FILES
        "${SOURCE_PATH}/lib/*.dll"
    )
    file(INSTALL    ${PYTORCH_DLL_FILES}
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(GLOB  PYTORCH_DEBUG_DLL_FILES
        "${DEBUG_SOURCE_PATH}/lib/*.dll"
    )
    file(INSTALL    ${PYTORCH_DEBUG_DLL_FILES}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    
    # .lib
    file(GLOB  PYTORCH_LIB_FILES
        "${SOURCE_PATH}/lib/*.lib"
    )
    file(INSTALL    ${PYTORCH_LIB_FILES}
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    file(GLOB  PYTORCH_DEBUG_LIB_FILES
        "${DEBUG_SOURCE_PATH}/lib/*.lib"
    )
    file(INSTALL    ${PYTORCH_DEBUG_LIB_FILES}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
else()
    file(COPY       ${SOURCE_PATH}/lib
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )
endif()

# remove packaged 3rd parties
# - Protobuf
file(GLOB       PYTORCH_PREBUILT_PROTOBUF_LIBS
    "${CURRENT_PACKAGES_DIR}/lib/libproto*${CMAKE_STATIC_LIBRARY_SUFFIX}"
    "${CURRENT_PACKAGES_DIR}/debug/lib/libproto*${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
file(REMOVE     ${PYTORCH_PREBUILT_PROTOBUF_LIBS})

message(STATUS "Removed Protobuf in libtorch. Will use that of the VcPkg")
foreach(removed_file_name ${PYTORCH_PREBUILT_PROTOBUF_LIBS})
    message(STATUS "Removed: ${removed_file_name}")
endforeach()


file(INSTALL    ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtorch
)

# License
file(DOWNLOAD https://raw.githubusercontent.com/pytorch/pytorch/master/LICENSE
              ${SOURCE_PATH}/copyright
)
file(INSTALL    ${SOURCE_PATH}/copyright
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtorch
)

if(WIN32)
    include(${CMAKE_CURRENT_LIST_DIR}/remove_empty_include_dirs.cmake)
endif()

# Any addition validation?
vcpkg_test_cmake(PACKAGE_NAME Torch)
