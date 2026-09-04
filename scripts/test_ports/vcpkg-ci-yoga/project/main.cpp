#include <yoga/Yoga.h>

int main() {
    YGNodeRef node = YGNodeNew();
    if (node == nullptr) return 1;
    YGNodeFree(node);
    return 0;
}
