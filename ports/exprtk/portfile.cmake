vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF f46bffcd6966d38a09023fb37ba9335214c9b959 
    SHA512 
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/exprtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
