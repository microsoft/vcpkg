#include <cstdio>
#include <vector>

#include <sail-c++/sail-c++.h>

int main()
{
    const std::vector<sail::codec_info> codec_infos = sail::codec_info::list();

    if (codec_infos.empty()) {
        std::fprintf(stderr, "No SAIL codecs were found\n");
        return 1;
    }

    for (const sail::codec_info& codec_info : codec_infos) {
        std::printf("Codec: %s\n", codec_info.name().c_str());
    }

    sail::context::finish();

    return 0;
}
