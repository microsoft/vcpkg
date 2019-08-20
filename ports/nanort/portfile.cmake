# Single header only library

include(vcpkg_common_functions)

function(shorten_ref REF SHORTENED_REF)
    set(REF_MAX_LENGTH 10)
    string(LENGTH ${REF} REF_LENGTH)
    math(EXPR FROM_REF ${REF_LENGTH}-${REF_MAX_LENGTH})
    if(FROM_REF LESS 0)
        set(FROM_REF 0)
    endif()
    string(SUBSTRING ${REF} ${FROM_REF} ${REF_LENGTH} SUB_REF)
    set(${SHORTENED_REF} ${SUB_REF} PARENT_SCOPE)
endfunction()

set(SOURCE_VERSION c85fe7a10be5baf8242c81288718c244f25d0183)
shorten_ref(${SOURCE_VERSION} SHORTED_VERSION)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lighttransport-nanort-${SHORTED_VERSION})

file(MAKE_DIRECTORY ${SOURCE_PATH})

# See ports/nlohmann-json/portfile.cmake
function(download_src SUBPATH SHA512)
    vcpkg_download_distfile(
        FILE
        URLS "https://raw.githubusercontent.com/lighttransport/nanort/master/${SUBPATH}"
        FILENAME "lighttransport-nanort-${SHORTED_VERSION}/${SUBPATH}"
        SHA512 ${SHA512}
    )
    get_filename_component(SUBPATH_DIR "${SOURCE_PATH}/${SUBPATH}" DIRECTORY)
    file(COPY ${FILE} DESTINATION ${SUBPATH_DIR})
endfunction()

download_src(
    nanort.h
    3e1f6f5fa295ebc472e37daf106c3871873f0bea4e3175cd4042b5649f581a90bfb9f2db989fa1994c82a2de78e40ecbcafd188b68bf10b5983a41b48e53dcbc
)

download_src(
    LICENSE
    454b304dcfae816d7a569ccbe29cc9c4bd68aa7ac41467bfa33b39aaf5be4620df5aeb6989319aaa04f305c053c068559b39c7a38c0bee1d4f194b2bc1aac240
)

file(COPY ${SOURCE_PATH}/nanort.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
