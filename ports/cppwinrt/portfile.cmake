include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppwinrt
    REF e4830e1aed38332d46f46c8e550f94ddc05c4410 # 2.0.191018.6
    SHA512 bcc24233c7e26d950644b0b0d3dd7bbc75af156905f68f0ad3209418ae30c08d262cb212d379bc93a00cda4dea80596cb5367123f927b2571bb0fd57e037e638
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppwinrt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppwinrt/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppwinrt/copyright)

# Copy the cppwinrt header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/10.0.16299.0/winrt/*)
file(
    COPY ${HEADER_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/winrt
    REGEX "\.(gitattributes|gitignore)$" EXCLUDE
)
