static const char norm_fg[] = "#e6e4cb";
static const char norm_bg[] = "#130914";
static const char norm_border[] = "#a19f8e";

static const char sel_fg[] = "#e6e4cb";
static const char sel_bg[] = "#5D6D8D";
static const char sel_border[] = "#e6e4cb";

static const char urg_fg[] = "#e6e4cb";
static const char urg_bg[] = "#2A588E";
static const char urg_border[] = "#2A588E";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
