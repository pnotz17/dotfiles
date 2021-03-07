/* See LICENSE file for copyright and license details. */
/* appearance */
static const unsigned int borderpx  					= 1;        								/* border pixel of windows */
static const unsigned int gappx							= 1;        								/* gaps between windows */
static const unsigned int snap								= 32;     								/* snap pixel */
static const int showbar											= 1;        								/* 0 means no bar */
static const int topbar												= 1;        								/* 0 means bottom bar */
static const char *fonts[]											= {"TerminessTTF Nerd Font:style=Medium:size=11:antialias=true:autohint=true","Noto Color Emoji:style=Regular:size=10:antialias=true:autohint=true","Font Awesome:size:10:antialias=true:autohint=true",};
static const char dmenufont[]								=   "TerminessTTF Nerd Font:style=Medium:size=11:antialias=true:autohint=true";
static const char col_bar[]										= "#080808";				// bar color
static const char  col_uwb[]									= "#B3AFC2";				// unfocused window border color
static const char  col_barfg[]									= "#B5B5B5"; 				// bar foreground color on right & left // make this a little lighter than the one below so tags & everything on the right are brigter or the same color
static const char  col_fttf[]										= "#B5B5B5"; 				// focused tag and tasklist foreground color
static const char col_httfwb[]								= "#2B2B2B";  				// highlighted tag color // tasklist border color // focused window border color
static const unsigned int baralpha						= 235;								// OPAQUE is defined to be 0xFF, same as 255. Choose your values between 0 and 255 where 255 is not transparent at all
static const unsigned int borderalpha				= 235;
static const char *colors[][3]									= {
	/*               					  fg         			bg				  border   */
	[SchemeNorm]	= { col_barfg,col_bar, col_uwb },
	[SchemeSel]		= { col_fttf,col_httfwb, col_httfwb},
};

static const unsigned int alphas[][3]      = {
	/*               					  fg      		  bg        		   border     */
	[SchemeNorm]	=	{ OPAQUE, baralpha, borderalpha },
	[SchemeSel]		=	{ OPAQUE, baralpha, borderalpha },
};
 
/* tagging */
static const char *tags[]	= { "01", "02", "03", "04", "05", "06", "07", "08", "09" };
//static const char *tags[]	= { "", "", "", "", "", "", "", "", "" }; 
//static const char *tags[]		= { "dev", "www", "code", "sys", "doc"};

static const Rule rules[] = {
	//* xprop(1):
	//* class     instance  title           tags mask    isfloating     monitor */
	{ "mpv",     NULL,       NULL,       0,            		1,           			-1 },
};

/* layout(s) */
#include "layouts.c"
static const float mfact     = 0.52; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	{ "[]=",		tile },    
	{ "><>",	NULL },    
	{ "[M]",		monocle },
	{ "HHH",      grid },
	{ NULL,		NULL },
};
/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       								KEY,      view,           		{.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           				KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             					KEY,      tag,            			{.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, 	KEY,      toggletag,      	{.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2]										= "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] 							= { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_bar, "-nf", col_barfg, "-sb",col_httfwb, "-sf",col_fttf, NULL };
static const char *termcmd[]									= { "st", NULL };
static const char *print_screen_cmd[]				= { "scrot", "-d3", "~/Pictures/Screenshots/%Y-%m-%d-%s_$wx$h.jpg", NULL };
static const char *upvol[]										= { "amixer", "set", "Master", "2+",     NULL };
static const char *downvol[]									= { "amixer", "set", "Master", "2-",     NULL };
static const char *webcmd[]									= { "qutebrowser", NULL };
static const char *filescmd[]									= { "pcmanfm", NULL };
#include "movestack.c"

static Key keys[] = {
	/* modifier                    				 	key        				function        							argument */
	{ MODKEY,                       				XK_p,				spawn,										{.v = dmenucmd } },
	{ MODKEY|ShiftMask,				XK_Return,		spawn,										{.v = termcmd } },
	{ MODKEY,                       				XK_b,				togglebar,								{0} },
	{ MODKEY,                       				XK_j,					focusstack,								{.i = +1 } },
	{ MODKEY,                       				XK_k,					focusstack,								{.i = -1 } },
	{ MODKEY,                       				XK_i,					incnmaster,     						{.i = +1 } },
	{ MODKEY,                       				XK_d,				incnmaster,     						{.i = -1 } },
	{ MODKEY,                       				XK_h,				setmfact,       							{.f = -0.05} },
	{ MODKEY,                       				XK_l,					setmfact,       							{.f = +0.05} },
	{ MODKEY|ShiftMask,				XK_j,					movestack,      						{.i = +1 } },
	{ MODKEY|ShiftMask,				XK_k,					movestack,								{.i = -1 } },
	{ MODKEY,                       				XK_Return, 	zoom,           							{0} },
	{ MODKEY,                       				XK_Tab,    		view,           								{0} },
	{ MODKEY|ShiftMask,				XK_c,					killclient,     								{0} },
	{ MODKEY,                       				XK_t,      			setlayout,      							{.v = &layouts[0]} },
	{ MODKEY,                       				XK_f,      			setlayout,      							{.v = &layouts[1]} },
	{ MODKEY,                       				XK_m,      			setlayout,      							{.v = &layouts[2]} },
	{ MODKEY,                       				XK_g,      			setlayout,      							{.v = &layouts[3]} },
	{ MODKEY|ControlMask,			XK_comma,  	cyclelayout,    						{.i = -1 } },
	{ MODKEY|ControlMask,           XK_period, 	cyclelayout,    						{.i = +1 } },
	{ MODKEY,                       				XK_space,  		setlayout,      							{0} },
	{ MODKEY|ShiftMask,            	XK_space,		togglefloating, 						{0} },
	{ MODKEY,                       				XK_0,      			view,           								{.ui = ~0 } },
	{ MODKEY|ShiftMask,            	XK_0,      			tag,            								{.ui = ~0 } },
	{ MODKEY,                       				XK_comma,	focusmon,       						{.i = -1 } },
	{ MODKEY,                       				XK_period, 		focusmon,       						{.i = +1 } },
	{ MODKEY|ShiftMask,            	XK_comma,  	tagmon,         							{.i = -1 } },
	{ MODKEY|ShiftMask,            	XK_period, 		tagmon,         							{.i = +1 } },
	{ MODKEY,                       				XK_minus,  	setgaps,        							{.i = -1 } },
	{ MODKEY,                       				XK_equal,  		setgaps,        							{.i = +1 } },
	{ MODKEY|ShiftMask,            	XK_equal,  		setgaps,        							{.i = 0  } },
	{ MODKEY|ShiftMask,				XK_q, quit,           												{0} },
	{ MODKEY|ShiftMask,				XK_b,	    		spawn,	   									{.v = webcmd } },
	{ MODKEY|ShiftMask,				XK_f,	    			spawn,	   									{.v = filescmd } },
	{ MODKEY|ShiftMask,				XK_p,      			spawn,          							SHCMD("~/.local/bin/power.sh") },
	{ MODKEY|ShiftMask,				XK_r,      			spawn,          							SHCMD("feh --no-fehbg --randomize --bg-scale ~/Pictures/Wallpapers/*") },
	{ 0,                            							XK_Print,			spawn,          							{.v = print_screen_cmd } },
    { 0,                            							XK_F12,			spawn,          							{.v = upvol   } },
	{ 0,                            							XK_F11,			spawn,          							{.v = downvol } },
	TAGKEYS(                        				XK_1,                      												0)
	TAGKEYS(                        				XK_2,                      												1)
	TAGKEYS(                        				XK_3,                      												2)
	TAGKEYS(                        				XK_4,                      												3)
	TAGKEYS(                        				XK_5,                      												4)
	TAGKEYS(                        				XK_6,                      												5)
	TAGKEYS(                        				XK_7,                      												6)
	TAGKEYS(                        				XK_8,                      												7)
	TAGKEYS(                        				XK_9,                      												8)
};

/* button definitions */
static Button buttons[] = {
	/* click                					event mask     button          		function        		argument */
	{ ClkLtSymbol,					0,              			Button1,        		setlayout,      		{0} },
	{ ClkLtSymbol,					0,              			Button3,        		setlayout,      		{.v = &layouts[2]} },
	{ ClkWinTitle,					0,              			Button2,        		zoom,           		{0} },
	{ ClkStatusText,				0,              			Button2,        		spawn,          		{.v = termcmd } },
	{ ClkTagBar,            			0,              			Button1,        		view,           			{0} },
	{ ClkTagBar,            			0,              			Button3,       		toggleview,    	{0} },
	{ ClkTagBar,            			MODKEY,		Button1,        		tag,           				{0} },
	{ ClkTagBar,            			MODKEY,		Button3,        		toggletag,      		{0} },
	{ ClkClientWin,         		MODKEY,		Button1,        		movemouse,      {0} },
	{ ClkClientWin,         		MODKEY,		Button2,        		togglefloating, 	{0} },
	{ ClkClientWin,         		MODKEY,		Button3,        		resizemouse,    	{0} },
};