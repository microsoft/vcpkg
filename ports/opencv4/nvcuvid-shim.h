// Installed as <nvcuvid.h> for OpenCV's cudacodec module.
//
// The NVIDIA Video Codec SDK is not redistributable, but the NVDEC API it
// describes is also published by NVIDIA under MIT in FFmpeg's nv-codec-headers
// (the ffnvcodec port). Those headers declare each entry point as a function
// *type* (tcuvidXxx) because FFmpeg resolves them with LoadLibrary at runtime.
// OpenCV links them instead, so declare the corresponding functions here. The
// import library is generated from nvcuvid.def; at run time the calls land in
// the driver's nvcuvid.dll either way.

#ifndef OPENCV_VCPKG_NVCUVID_H
#define OPENCV_VCPKG_NVCUVID_H

#include <cuda.h>

#include <ffnvcodec/dynlink_nvcuvid.h>

#ifdef __cplusplus
extern "C" {
#endif

extern tcuvidCreateVideoSource cuvidCreateVideoSource;
extern tcuvidCreateVideoSourceW cuvidCreateVideoSourceW;
extern tcuvidDestroyVideoSource cuvidDestroyVideoSource;
extern tcuvidSetVideoSourceState cuvidSetVideoSourceState;
extern tcuvidGetVideoSourceState cuvidGetVideoSourceState;
extern tcuvidGetSourceVideoFormat cuvidGetSourceVideoFormat;
extern tcuvidGetSourceAudioFormat cuvidGetSourceAudioFormat;

extern tcuvidCreateVideoParser cuvidCreateVideoParser;
extern tcuvidParseVideoData cuvidParseVideoData;
extern tcuvidDestroyVideoParser cuvidDestroyVideoParser;

extern tcuvidGetDecoderCaps cuvidGetDecoderCaps;
extern tcuvidCreateDecoder cuvidCreateDecoder;
extern tcuvidDestroyDecoder cuvidDestroyDecoder;
extern tcuvidDecodePicture cuvidDecodePicture;
extern tcuvidGetDecodeStatus cuvidGetDecodeStatus;
extern tcuvidReconfigureDecoder cuvidReconfigureDecoder;

extern tcuvidMapVideoFrame64 cuvidMapVideoFrame64;
extern tcuvidUnmapVideoFrame64 cuvidUnmapVideoFrame64;

extern tcuvidCtxLockCreate cuvidCtxLockCreate;
extern tcuvidCtxLockDestroy cuvidCtxLockDestroy;
extern tcuvidCtxLock cuvidCtxLock;
extern tcuvidCtxUnlock cuvidCtxUnlock;

#ifdef __cplusplus
}
#endif

// dynlink_cuviddec.h defines __CUVID_DEVPTR64 and aliases the typedef names;
// the SDK header aliases the function names to match.
#define cuvidMapVideoFrame cuvidMapVideoFrame64
#define cuvidUnmapVideoFrame cuvidUnmapVideoFrame64

#endif
