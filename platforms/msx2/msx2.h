#ifndef MSX2_H
#define MSX2_H

/* __sdcccall function attribute on SDCC 4.1.12 and later */
#if (__SDCC_VERSION_MAJOR > 4 || \
    (__SDCC_VERSION_MAJOR == 4 && __SDCC_VERSION_MINOR > 1) || \
    (__SDCC_VERSION_MAJOR == 4 && __SDCC_VERSION_MINOR == 1 && __SDCC_VERSION_PATCH >= 12))
#define SDCCCALL0 __sdcccall(0)
#else
#define SDCCCALL0
#endif

#endif /* MSX2_H */
