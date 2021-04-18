import argparse
import itertools
import sys
import dataclasses
from operator import attrgetter
from pathlib import Path
import re
from typing import TextIO, Iterable, Dict, Callable, Pattern, List, Union, Tuple, Set, NamedTuple


class Codec(NamedTuple):
    name: str        #: Name of codec (from source, for configure script)
    encoder: bool    #: Whether it is an encoder or a decoder


class Feature(NamedTuple):
    name: str                              #: Group name of the codec feature
    description: str                       #: Descriptive name for codecs in this group
    match: Callable[[Codec], bool]         #: Function to determine if codec is in group
    supported: bool = True                 #: Whether feature is already supported in vcpkg
    depends: str = ""                      #: Vcpkg dependency if any (Build-Depends)
    options_enable: Tuple[str, ...] = ()   #: Configure flags needed for feature (without "")
    static_linkage_variable: str = ""      #: Cmake variable to set on static linkage in vcpkg portfile.cmake script
    license: str = ""                      #: The license if not lgpl ("gpl", "version3", "nonfree")


def get_codecs(ffmpeg_path: Path) -> Set[Codec]:
    """Parse libavcodec/allcodecs.c to get a list of all codecs."""
    re_codec: Pattern[str] = re.compile("extern AVCodec ff_(.*)_(..)coder")
    return set([
        Codec(name=match.group(1), encoder=(match.group(2) == "en"))
        for match in re_codec.finditer(
            (ffmpeg_path / "libavcodec" / "allcodecs.c").read_text())])


def get_media_types(ffmpeg_path: Path, codecs: Set[Codec]) -> Dict[Codec, str]:
    """Parse all source files from libavcodec to try to infer the media type
    of every codec.
    """

    def guess_media_type(codec_name: str) -> str:
        """Guess media type of codecs that we cannot infer from source."""
        if codec_name.startswith(
                ("h263", "h264", "hevc", "mpeg", "msmpeg", "vc1", "vp", "wmv")):
            return "video"
        elif codec_name.startswith(
                ("dsd_", "pcm_", "adpcm_", "aac_", "ac3_", "mp3_", "mjpeg_")):
            return "audio"
        elif codec_name.endswith(("_dpcm", "_at")):
            return "audio"
        raise RuntimeError("no media type found for {0}".format(name))

    media_types: Dict[Codec, str] = {}

    re_codec: Pattern[str] = re.compile("AVCodec ff_(.*)_(..)coder")
    for source_file in (ffmpeg_path / "libavcodec").rglob("*.c"):
        if source_file.name == "allcodecs.c":
            continue
        source_str: str = source_file.read_text()
        for match in re_codec.finditer(source_str):
            name: str = match.group(1)
            encdec: str = match.group(2)
            if name.startswith("#") or name.startswith(" "):
                # it's #DEFINE'd: cannot get the information in this case
                continue
            codec = Codec(name=name, encoder=(encdec == "en"))
            if codec not in codecs:
                raise RuntimeError("unexpected codec {0} in {1}".format(
                    codec, source_file))
            re_media_type: Pattern[str] = re.compile(
                "AVCodec ff_{0}_{1}coder = [{{][^}}]+"
                "[.]type\\s+=\\s+AVMEDIA_TYPE_([A-Z]+)".format(name, encdec),
                re.DOTALL)
            match_media_type = re_media_type.search(source_str)
            if not match_media_type:
                raise RuntimeError(
                    "failed to identify {0} media type from {1}".format(
                        codec, source_file))
            media_type = match_media_type.group(1).lower()
            if media_type not in {"audio", "video", "subtitle"}:
                raise RuntimeError(
                    "bad media type {0} in {1}".format(media_type, source_file))
            media_types[codec] = media_type

    # guess remaining ones
    for codec in codecs - set(media_types.keys()):
        media_types[codec] = guess_media_type(codec.name)

    return media_types


def get_features(codecs: Set[Codec], media_types: Dict[Codec, str]
                 ) -> Dict[Codec, Feature]:

    def equals(s: str) -> Callable[[Codec], bool]:
        def _(codec: Codec) -> bool:
            return codec.name == s
        return _

    def startswith(prefix: Union[str, Tuple[str, ...]]) -> Callable[[Codec], bool]:
        def _(codec: Codec) -> bool:
            return codec.name.startswith(prefix)
        return _

    def endswith(suffix: Union[str, Tuple[str, ...]]) -> Callable[[Codec], bool]:
        def _(codec: Codec) -> bool:
            return codec.name.endswith(suffix)
        return _

    def has_media_type(typ: str) -> Callable[[Codec], bool]:
        def _(codec: Codec) -> bool:
            return media_types[codec] == typ
        return _

    def any_(conditions: Iterable[Callable[[Codec], bool]]) -> Callable[[Codec], bool]:
        def _(codec: Codec) -> bool:
            return any(cond(codec) for cond in conditions)
        return _

    def all_(conditions: Iterable[Callable[[Codec], bool]]) -> Callable[[Codec], bool]:
        def _(codec: Codec) -> bool:
            return all(cond(codec) for cond in conditions)

        return _

    # note: features are matched in order of this list
    features_database: List[Feature] = [
        # hardware accelerated features
        Feature(name="amf",
                description="AMD Advanced Media Framework H.264/HEVC",
                match=endswith("_amf"),
                supported=False,
                ),
        Feature(name="audiotoolbox",
                description="Apple AudioToolbox AAC/AC3/ALAC/iLBC/MP3/...",
                match=endswith("_at"),
                options_enable=("audiotoolbox",),
                supported=False,
                ),
        Feature(name="crystalhd",
                description="CrystalHD H.264/MPEG/VC1/WMV3/...",
                match=endswith("_crystalhd"),
                supported=False,
                ),
        Feature(name="cuvid",
                description="Nvidia CUVID H.264/HEVC/MPEG/VP/...",
                match=endswith("_cuvid"),
                depends="ffnvcodec",
                options_enable=("ffnvcodec", "cuvid"),
                static_linkage_variable="ENABLE_NVCODEC",
                ),
        Feature(name="mediacodec",
                description="Android MediaCodec H.264/HEVC/MPEG/VP/...",
                match=endswith("_mediacodec"),
                supported=False,
                ),
        Feature(name="nvenc",
                description="Nvidia NVENC H.264/HEVC",
                match=any_([startswith("nvenc"), endswith("nvenc")]),
                depends="ffnvcodec",
                options_enable=("ffnvcodec", "nvenc"),
                static_linkage_variable="ENABLE_NVCODEC",
                ),
        Feature(name="nvdec",
                description="Nvidia NVENC H.264/HEVC",
                match=any_([startswith("nvdec"), endswith("nvdec")]),
                depends="ffnvcodec",
                options_enable=("ffnvcodec", "nvdec"),
                static_linkage_variable="ENABLE_NVCODEC",
                ),
        Feature(name="mediafoundation-audio",
                description="Windows Media Foundation AAC/AC3/MP3",
                match=all_([endswith("_mf"), has_media_type("audio")]),
                options_enable=("mediafoundation",),
                supported=False,
                ),
        Feature(name="mediafoundation-video",
                description="Windows Media Foundation H.264/HEVC",
                match=all_([endswith("_mf"), has_media_type("video")]),
                options_enable=("mediafoundation",),
                supported=False,
                ),
        Feature(name="mmal",
                description="Multimedia Abstraction Layer H.264/MPEG/VC1",
                match=endswith("_mmal"),
                supported=False,
                ),
        Feature(name="omx",
                description="OpenMAX IL H.264/MPEG4",
                match=endswith("_omx"),
                supported=False,
                ),
        Feature(name="qsv",
                description="Intel Quick Sync Video H.264/HEVC/MPEG/VP/...",
                match=endswith("_qsv"),
                supported=False,
                ),
        Feature(name="rkmpp",
                description="RockChip MPP H.264/HEVC/VP/...",
                match=endswith("_rkmpp"),
                supported=False,
                ),
        Feature(name="v4l2m2m",
                description="V4L2 mem2mem H.264/HEVC/MPEG/VP/...",
                match=endswith("_v4l2m2m"),
                options_enable=("v4l2-m2m",),
                supported=False,
                ),
        Feature(name="vaapi",
                description="Video Acceleration API H.264/HEVC/MPEG/VP/...",
                match=endswith("_vaapi"),
                options_enable=("vaapi",),
                supported=False,
                ),
        Feature(name="videotoolbox",
                description="Apple VideoToolbox H.264/HEVC/MPEG/...",
                match=endswith("_videotoolbox"),
                supported=False,
                ),
        # native features
        Feature(name="aac", match=startswith("aac"), description="AAC (Advanced Audio Coding)"),
        Feature(name="ac3", match=startswith("ac3"), description="Dolby AC-3"),
        Feature(name="adpcm", match=startswith("adpcm_"), description="ADPCM"),
        Feature(name="eac3", match=startswith("eac3"), description="Enhanced AC-3"),
        Feature(name="mp1", match=startswith("mp1"), description="MP1"),
        Feature(name="mp2", match=startswith("mp2"), description="MP2"),
        Feature(name="mp3", match=startswith("mp3"), description="MP3"),
        Feature(name="pcm", match=startswith("pcm_"), description="PCM"),
        Feature(name="vorbis", match=startswith("vorbis"), description="Vorbis"),
        Feature(name="wavpack", match=startswith("wavpack"), description="WavPack"),
        Feature(name="wma", match=startswith("wma"), description="Windows Media Audio"),
        Feature(name="ffv1", match=startswith("ffv1"), description="FFmpeg video codec #1"),
        Feature(name="huffyuv", match=startswith(("huffyuv", "ffvhuff", "hymt")), description="HuffYUV"),
        Feature(name="flac", match=startswith("flac"), description="FLAC (Free Lossless Audio Codec)"),
        Feature(name="flv", match=startswith("flv"), description="flv"),
        Feature(name="h261", match=startswith("h261"), description="H.261"),
        Feature(name="h263", match=startswith("h263"), description="H.263"),
        Feature(name="h264", match=startswith("h264"), description="H.264"),
        Feature(name="hevc", match=startswith("hevc"), description="HEVC"),
        Feature(name="lagarith", match=startswith("lagarith"), description="Lagarith lossless"),
        Feature(name="mpeg1", match=startswith(("mpeg1", "mpegvideo")), description="MPEG1"),
        Feature(name="mpeg2", match=startswith("mpeg2"), description="MPEG2"),
        Feature(name="mpeg4", match=startswith(("mpeg4", "msmpeg4")), description="MPEG4"),
        Feature(name="prores", match=startswith("prores"), description="Apple ProRes"),
        Feature(name="rawvideo", match=startswith("rawvideo"), description="raw video"),
        Feature(name="subrip", match=startswith(("srt", "subrip")), description="SubRip subtitle"),
        Feature(name="text", match=startswith("text"), description="raw text subtitle"),
        Feature(name="theora", match=startswith("theora"), description="Theora"),
        Feature(name="vp3", match=startswith("vp3"), description="VP3"),
        Feature(name="vp4", match=startswith("vp4"), description="VP4"),
        Feature(name="vp5", match=startswith("vp5"), description="VP5"),
        Feature(name="vp6", match=startswith("vp6"), description="VP6"),
        Feature(name="vp7", match=startswith("vp7"), description="VP7"),
        Feature(name="vp8", match=startswith("vp8"), description="VP8"),
        Feature(name="vp9", match=startswith("vp9"), description="VP9"),
        Feature(name="webp", match=startswith("webp"), description="WebP"),
        Feature(name="wmv", match=startswith("wmv"), description="Windows Media Video"),
        # external features
        Feature(name="libaom-av1",
                match=startswith("libaom_av1"),
                description="AV1",
                supported=False),
        Feature(name="libaribb24",
                match=startswith("libaribb24"),
                description="ARIB STD-B24",
                supported=False),
        Feature(name="libcelt",
                match=startswith("libcelt"),
                description="Xiph CELT",
                supported=False),
        Feature(name="libcodec2",
                match=startswith("libcodec2"),
                description="codec2",
                supported=False),
        Feature(name="libdav1d",
                match=startswith("libdav1d"),
                description="AV1",
                depends="dav1d",
                options_enable=("libdav1d",),
                static_linkage_variable="ENABLE_DAV1D"),
        Feature(name="libdavs2",
                match=startswith("libdavs2"),
                description="AVS2-P2/IEEE1857.4",
                supported=False),
        Feature(name="libfdk-aac",
                match=startswith("libfdk_aac"),
                description="Fraunhofer FDK AAC",
                depends="fdk-aac",
                options_enable=("libfdk-aac",),
                static_linkage_variable="ENABLE_FDKAAC",
                license="nonfree"),
        Feature(name="libgsm",
                match=startswith("libgsm"),
                description="GSM",
                supported=False),
        Feature(name="libilbc",
                match=startswith("libilbc"),
                description="iLBC",
                depends="libilbc",
                options_enable=("libilbc",),
                static_linkage_variable="ENABLE_ILBC"),
        Feature(name="libkvazaar",
                match=startswith("libkvazaar"),
                description="HEVC",
                supported=False),
        Feature(name="libmp3lame",
                match=startswith("libmp3lame"),
                description="MP3",
                depends="mp3lame",
                options_enable=("libmp3lame",),
                static_linkage_variable="ENABLE_LAME"),
        Feature(name="libopencore", match=startswith("libopencore"),
                description="OpenCORE AMR-NB/WB (Adaptive Multi-Rate Narrow-Band/Wide-Band)",
                supported=False),
        Feature(name="libopenh264",
                match=startswith("libopenh264"),
                description="H.264",
                depends="openh264", supported=False),
        Feature(name="libopenjpeg", match=startswith("libopenjpeg"), description="OpenJPEG JPEG 2000",
                depends="openjpeg",
                options_enable=("libopenjpeg",),
                static_linkage_variable="ENABLE_OPENJPEG"),
        Feature(name="libopus",
                match=startswith("libopus"),
                description="Opus",
                depends="opus",
                options_enable=("libopus",),
                static_linkage_variable="ENABLE_OPUS"),
        Feature(name="librav1e", match=startswith("librav1e"), description="AV1",
                supported=False),
        Feature(name="librsvg", match=startswith("librsvg"), description="Librsvg rasterizer",
                supported=False),
        Feature(name="libshine", match=startswith("libshine"), description="MP3",
                supported=False),
        Feature(name="libspeex", match=startswith("libspeex"), description="Speex",
                depends="speex",
                options_enable=("libspeex",),
                static_linkage_variable="ENABLE_SPEEX"),
        Feature(name="libsvtav1", match=startswith("libsvtav1"), description="SVT-AV1",
                supported=False),
        Feature(name="libtheora",
                match=startswith("libtheora"),
                description="Theora",
                depends="libtheora",
                options_enable=("libtheora",),
                static_linkage_variable="ENABLE_THEORA"),
        Feature(name="libtwolame", match=startswith("libtwolame"), description="MP2",
                depends="libtwolame", supported=False),
        Feature(name="libvo-amrwbenc",
                match=startswith("libvo_amrwbenc"),
                description="Android VisualOn AMR-WB",
                supported=False),
        Feature(name="libvorbis",
                match=startswith("libvorbis"),
                description="Vorbis",
                depends="libvorbis",
                options_enable=("libvorbis",),
                static_linkage_variable="ENABLE_VORBIS"),
        Feature(name="libvpx",
                match=startswith("libvpx_"),
                description="VP8/VP9",
                depends="libvpx",
                options_enable=("libvpx",),
                static_linkage_variable="ENABLE_VPX"),
        Feature(name="libwavpack",
                match=startswith("libwavpack"),
                description="WavPack",
                depends="wavpack",
                options_enable=("libwavpack",),
                static_linkage_variable="ENABLE_WAVPACK"),
        Feature(name="libwebp",
                match=startswith("libwebp"),
                description="WebP",
                depends="libwebp",
                options_enable=("libwebp",),
                static_linkage_variable="ENABLE_WEBP"),
        Feature(name="libx262",
                match=startswith("libx262"),
                description="H.262",
                depends="x262",
                options_enable=("libx262",),
                license="gpl",
                supported=False),
        Feature(name="libx264",
                match=startswith("libx264"),
                description="H.264",
                depends="x264",
                options_enable=("libx264",),
                static_linkage_variable="ENABLE_X264",
                license="gpl"),
        Feature(name="libx265",
                match=startswith("libx265"),
                description="H.265",
                depends="x265",
                options_enable=("libx265",),
                static_linkage_variable="ENABLE_X265",
                license="gpl"),
        Feature(name="libxavs",
                match=equals("libxavs"),
                description="AVS",
                supported=False),
        Feature(name="libxavs2",
                match=equals("libxavs2"),
                description="AVS2-P2/IEEE1857.4",
                supported=False),
        Feature(name="libxvid",
                match=startswith("libxvid"),
                description="MPEG4",
                supported=False),
        Feature(name="libzvbi",
                match=startswith("libzvbi"),
                description="DVB teletext",
                supported=False),
        Feature(name="unsupported",
                match=startswith("lib"),  # catch all other unsupported external codecs
                description="unsupported",
                supported=False),
        # features for codecs not covered otherwise
        # all these codecs must be native, so every non-native (external) codec must be matched
        # by one of the preceding rules
        Feature(name="other-audio", match=has_media_type("audio"), description="other audio"),
        Feature(name="other-video", match=has_media_type("video"), description="other video"),
        Feature(name="other-subtitle", match=has_media_type("subtitle"), description="other subtitle"),
    ]

    # features to match only for encoders (in case encoder and decoder have different dependencies)
    decoder_features_database: List[Feature] = [
        Feature(name="hap", match=equals("hap"), description="Vidvox Hap"),
    ]

    # features to match only for decoders (in case encoder and decoder have different dependencies)
    encoder_features_database: List[Feature] = [
        Feature(name="hap", match=equals("hap"), description="Vidvox Hap",
                depends="snappy",
                options_enable=("libsnappy",),
                static_linkage_variable="ENABLE_SNAPPY",
                )
    ]

    def get_feature(codec: Codec):
        for feature in (encoder_features_database if codec.encoder else decoder_features_database) + features_database:
            if feature.match(codec):
                return feature
        raise RuntimeError("feature not found")

    return dict((codec, get_feature(codec)) for codec in codecs)


@dataclasses.dataclass
class Data:
    ffmpeg_path: Path
    codecs: List[Codec] = dataclasses.field(init=False, default_factory=list)
    codec_media_type: Dict[Codec, str] = dataclasses.field(init=False, default_factory=dict)
    codec_feature: Dict[Codec, Feature] = dataclasses.field(init=False, default_factory=dict)
    features: List[Feature] = dataclasses.field(init=False, default_factory=list)
    features_decode: List[Feature] = dataclasses.field(init=False, default_factory=list)
    features_encode: List[Feature] = dataclasses.field(init=False, default_factory=list)
    media_types: List[str] = dataclasses.field(init=False, default_factory=list)

    def __post_init__(self):
        # get all the information from the source files
        codecs: Set[Codec] = get_codecs(self.ffmpeg_path)
        media_types: Dict[Codec, str] = get_media_types(self.ffmpeg_path, codecs)
        features: Dict[Codec, Feature] = get_features(codecs, media_types)
        # keep information we need
        self.codecs: List[Codec] = sorted(codec for codec in codecs if features[codec].supported)
        self.codec_feature = dict((codec, features[codec]) for codec in self.codecs)
        self.codec_media_type = dict((codec, media_types[codec]) for codec in self.codecs)
        self.features = sorted(set(features[codec] for codec in self.codecs), key=attrgetter("name"))
        self.features_decode = sorted(set(features[codec] for codec in self.codecs if not codec.encoder))
        self.features_encode = sorted(set(features[codec] for codec in self.codecs if codec.encoder))
        self.media_types = sorted(set(self.codec_media_type.values()))

    def get_feature_decoders(self, feature: Feature) -> Iterable[Codec]:
        return (codec for codec in self.codecs if self.codec_feature[codec] == feature and not codec.encoder)

    def get_feature_encoders(self, feature: Feature) -> Iterable[Codec]:
        return (codec for codec in self.codecs if self.codec_feature[codec] == feature and codec.encoder)

    def has_feature_media_type(self, feature: Feature, media_type: str) -> bool:
        return any(self.codec_feature[codec] == feature and self.codec_media_type[codec] == media_type
                   for codec in self.codecs)


def generate_portfile_code(stream: TextIO, ffmpeg_path: Path):
    print("# generated by vcpkg-parse-codecs.py", file=stream)
    print(file=stream)
    data = Data(ffmpeg_path)

    conf_all = sorted(set(itertools.chain.from_iterable(feature.options_enable for feature in data.features)))
    print(f'list(APPEND OPTIONS_DISABLE {" ".join(conf_all)})', file=stream)
    for decode in (True, False):
        decenc = "decoder" if decode else "encoder"
        for feature in (data.features_decode if decode else data.features_encode):
            if feature.options_enable:
                print(
                    f'feature_list({decenc}-{feature.name:16}'
                    f' APPEND OPTIONS_ENABLE {" ".join(feature.options_enable)})',
                    file=stream)

    static_linkage_variables = sorted(set(feature.static_linkage_variable for feature in data.features
                                          if feature.static_linkage_variable))
    for static_linkage_variable in static_linkage_variables:
        print(f'set({static_linkage_variable} OFF)', file=stream)

    for decode in (True, False):
        decenc = "decoder" if decode else "encoder"
        for feature in (data.features_decode if decode else data.features_encode):
            if feature.static_linkage_variable:
                print(f'feature_set({decenc}-{feature.name:16}'
                      f' {feature.static_linkage_variable:16} ${{STATIC_LINKAGE}})',
                      file=stream)

    for codec in data.codecs:
        feature = data.codec_feature[codec]
        outvar = "ENCODERS" if codec.encoder else "DECODERS"
        decenc = "encoder" if codec.encoder else "decoder"
        print(
            f'feature_list({decenc}-{feature.name:16}'
            f' APPEND {outvar} {codec.name:20})', file=stream)


def generate_control_code(stream: TextIO, ffmpeg_path: Path):
    print("# generated by vcpkg-parse-codecs.py", file=stream)
    print(file=stream)
    data = Data(ffmpeg_path)

    for decode in (True, False):
        decenc = "decoder" if decode else "encoder"
        decenc_features = data.features_decode if decode else data.features_encode

        print(f"Feature: {decenc}-all", file=stream)
        print(
            "Build-Depends: ffmpeg[core,%s]" % ",".join(
                f"{decenc}-all-{media_type}"
                for media_type in data.media_types),
            file=stream)
        print(f"Description: All native {decenc}s", file=stream)
        print(file=stream)

        for media_type in data.media_types:
            print(f"Feature: {decenc}-all-{media_type}", file=stream)
            native_deps = ["core"] + [
                f"{decenc}-{feature.name}" for feature in decenc_features
                if data.has_feature_media_type(feature, media_type)
                and not feature.depends]
            print(f"Build-Depends: ffmpeg[{','.join(native_deps)}]", file=stream)
            print(f"Description: All native {media_type} {decenc}s", file=stream)
            print(file=stream)

        for feature in decenc_features:
            print(f"Feature: {decenc}-{feature.name}", file=stream)
            ffmpeg_deps = ["core", "avcodec"] + ([feature.license] if feature.license else [])
            deps = [f"ffmpeg[{','.join(ffmpeg_deps)}]"] + ([feature.depends] if feature.depends else [])
            print(f"Build-Depends: {', '.join(deps)}", file=stream)
            if not feature.depends:
                print(f"Description: {feature.description} {decenc}(s)", file=stream)
            else:
                print(f"Description: {feature.description} {decenc}(s) using {feature.depends}", file=stream)
            print(file=stream)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate vcpkg code for the ffmpeg port')
    parser.add_argument(
        'source', help='Location of ffmpeg source code')
    parser.add_argument(
        '--portfile', action='store_true', help='Generate portfile.cmake code')
    parser.add_argument(
        '--control', action='store_true', help='Generate CONTROL code')
    args = parser.parse_args()
    if args.portfile:
        generate_portfile_code(sys.stdout, Path(args.source))
    if args.control:
        generate_control_code(sys.stdout, Path(args.source))
