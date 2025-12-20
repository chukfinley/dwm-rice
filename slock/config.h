/* slock configuration - with Xresources support */

/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nogroup";

/* default colors - these can be overridden by Xresources */
static char color0[8] = "#1a1b26";  /* init - before first key press */
static char color1[8] = "#ff6b6b";  /* input - wrong password */
static char color2[8] = "#7aa2f7";  /* input - typing */
static char color3[8] = "#1a1b26";  /* caps lock indicator */

/*
 * Xresources preferences to load at startup (use xrdb to set these)
 * slock.color0: background/init color
 * slock.color1: input/failure color
 * slock.color2: input/typing color
 * slock.color3: caps lock color
 */
static ResourcePref resources[] = {
    { "color0", STRING, &color0 },
    { "color1", STRING, &color1 },
    { "color2", STRING, &color2 },
    { "color3", STRING, &color3 },
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;
