if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dnp3/opendnp3
    REF 3.1.1
    SHA512 2d7b26753fa03596ab73944236e5f1d82656f38248cc23fd00f7a2cdac27f481e5fe51e68b5896b6740db1a6d9560f0262e473648e001601125f4af8b4a652c2
)

file(READ "${SOURCE_PATH}/deps/ser4cpp.cmake" ser4cpp_cmake)
if(ser4cpp_cmake MATCHES "https://github\\.com/automatak/ser4cpp/archive/([0-9a-f]*)\\.zip")
    vcpkg_from_github(
        OUT_SOURCE_PATH ser4cpp_src
        REPO automatak/ser4cpp
        REF "${CMAKE_MATCH_1}"
        SHA512 cd8d634c0e9fadda357bdd832c382189461f4707ced4834604668df0aa4e396333cce8d676d4f98ba1b414664228518e9a24c6456204b9d96a5f2df078bada2c
    )
else()
    message(FATAL_ERROR "Unable to determine version of ser4cpp")
endif()

file(READ "${SOURCE_PATH}/deps/exe4cpp.cmake" exe4cpp_cmake)
if(exe4cpp_cmake MATCHES "https://github\\.com/automatak/exe4cpp/archive/([0-9a-f]*)\\.zip")
    vcpkg_from_github(
        OUT_SOURCE_PATH exe4cpp_src
        REPO automatak/exe4cpp
        REF "${CMAKE_MATCH_1}"
        SHA512 c8946db752c0f8499d21c2da96b84676b8768954bcb1964f4c444c731d9871d8978cb96fe89b1125e91b861aef0984bdd943a4dccb91d17ba43f22c57673b7b2
    )
else()
    message(FATAL_ERROR "Unable to determine version of exe4cpp")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/opendnp3-config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/deps/" DESTINATION "${SOURCE_PATH}/deps/")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATICLIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls DNP3_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDNP3_STATIC_LIBS=${STATICLIBS}
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
        -DFETCHCONTENT_SOURCE_DIR_SER4CPP=${ser4cpp_src}
        -DFETCHCONTENT_SOURCE_DIR_EXE4CPP=${exe4cpp_src}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)