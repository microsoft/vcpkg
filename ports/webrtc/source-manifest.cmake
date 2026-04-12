set(WEBRTC_SOURCE_URL "https://webrtc.googlesource.com/src")
set(WEBRTC_SOURCE_REF "aa217206b9ce8b929dc56d112d670a5931ef8cc1")

declare_webrtc_repo(build
    DESTINATION "build"
    URL "https://chromium.googlesource.com/chromium/src/build"
    REF "f123ee3617656ae843bd7f68f173c651fe2ec4bf"
    PATCHES_VAR BUILD_PATCHES
)
declare_webrtc_repo(buildtools
    DESTINATION "buildtools"
    URL "https://chromium.googlesource.com/chromium/src/buildtools"
    REF "95ed44cf5f06dbb5861030b91c9db9ccb4316762"
)
declare_webrtc_repo(rnnoise
    DESTINATION "third_party/rnnoise"
    URL "https://github.com/xiph/rnnoise.git"
    REF "c9137adac37fe21ede831f8a0aa31c17560c01e7"
    PATCHES_VAR RNNOISE_PATCHES
)

declare_webrtc_generated_external(third_party_root PHASE pre_absl)
declare_webrtc_generated_external(testing PHASE pre_absl)
declare_webrtc_generated_external(tools PHASE pre_absl)
declare_webrtc_generated_external(libsrtp LIB_ROOT_VAR LIBSRTP_LIB_ROOT)
declare_webrtc_generated_external(libyuv LIB_ROOT_VAR LIBYUV_LIB_ROOT)
declare_webrtc_generated_external(libvpx LIB_ROOT_VAR LIBVPX_LIB_ROOT)
declare_webrtc_generated_external(opus LIB_ROOT_VAR OPUS_LIB_ROOT)
declare_webrtc_generated_external(libaom LIB_ROOT_VAR LIBAOM_LIB_ROOT)
declare_webrtc_generated_external(jsoncpp LIB_ROOT_VAR JSONCPP_LIB_ROOT)
declare_webrtc_generated_external(pffft LIB_ROOT_VAR PFFFT_LIB_ROOT)
declare_webrtc_generated_external(alsa)
declare_webrtc_generated_external(pulseaudio)
declare_webrtc_generated_external(rnnoise)
declare_webrtc_generated_external(dav1d)
declare_webrtc_generated_external(llvm-libc)
declare_webrtc_generated_external(protobuf)
declare_webrtc_generated_external(googletest)
declare_webrtc_generated_external(catapult)
declare_webrtc_generated_external(nasm TOOL_PATH_VAR WEBRTC_YASM_PROGRAM)
