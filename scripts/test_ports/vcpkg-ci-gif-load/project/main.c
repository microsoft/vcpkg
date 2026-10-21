#include <gif_load.h>
#include <stdbool.h>

static const unsigned char gif_data[] = { 0x47 };
static void frame_writer(void *anim, struct GIF_WHDR *whdr)
{
    (void)anim;
    (void)whdr;
}

int main(void)
{
    const bool success = GIF_Load((void *)gif_data, (long)sizeof(gif_data), frame_writer, 0, 0, 0) == 1;
    return 0;
}
