extern "C" {
    void flib_(int*);
}

int main()
{
    int n = 42;
    flib_(&n);
    return 0;
}
