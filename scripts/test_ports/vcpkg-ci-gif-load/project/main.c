#include <gif_load.h>

static const unsigned char gif_data[] = { 0x47 };
static void frame_writer(void *anim, struct GIF_WHDR *whdr)
{
    (void)anim; (void)whdr;
}

int main(void)
{
    bool success = GIF_Load((void *)gif_data, (long)sizeof(gif_data), frame_writer, 0, 0, 0) == 1 ? 0 : 1;
    return 0;
}
