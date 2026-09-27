#include <graphite2/Font.h>

int main(void)
{
    gr_face* face = gr_make_file_face("does-not-exist.ttf", gr_face_default);
    if (face) {
        gr_face_destroy(face);
    }

    return 0;
}
