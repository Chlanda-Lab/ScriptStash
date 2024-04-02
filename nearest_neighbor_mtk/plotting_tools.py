import seaborn as sns

# Get current rcParams with: 
def rcparams():
    import matplotlib
    print(matplotlib.rcParams)
    
def cm2in(*vals):
    """Convert centimeter to inch for matplotlib"""
    if len(vals) == 1:
        return vals[0] / 2.54
    return tuple(map(cm2in, vals))

def mm2in(*vals):
    """Convert millimeter to inch for matplotlib"""
    if len(vals) == 1:
        return vals[0] / 25.4
    return tuple(map(mm2in, vals))


def flierprops():
    """Nice flier props for boxplots
    Cannot be set in rcparams because they are overwritten by Seaborn
    """
    return dict(markersize=0.5)
    
def _set_default(context: str, style: str = 'ticks', linewidth: int = 1, override=None):
    if override is None:
        override = dict()
    sns.set_theme(context=context,
                  style=style,
                  rc={**{
                      'figure.constrained_layout.use': True,
                      # Font sizes: between 5 and 8
                      'text.color': 'black',
                      'axes.edgecolor': 'black',
                      'axes.labelcolor': 'black',
                      'axes.titlecolor': 'black',
                      'font.sans-serif': 'Liberation Sans',
                      'font.weight': 'normal',
                      'figure.titleweight': 'normal',
                      'axes.titleweight': 'normal',
                      'axes.labelweight': 'normal',
                      'font.size': 6,
                      'axes.titlesize': 6,
                      'axes.labelsize': 6,
                      'legend.title_fontsize': 6,
                      'legend.fontsize': 5,
                      'xtick.labelsize': 5,
                      'ytick.labelsize': 5,
                      "axes.titlepad": 2.0, 
                      'axes.labelpad': 1.0,
                      'legend.markerscale': 1,
                      'axes.linewidth': linewidth/2,
                      'xtick.color': 'black',
                      'ytick.color': 'black',
                      'xtick.major.size': linewidth*2,
                      'ytick.major.size': linewidth*2,
                      'xtick.major.width': linewidth/2,
                      'ytick.major.width': linewidth/2,
                      'xtick.major.pad': 1,
                      'ytick.major.pad': 1,
                      'xtick.minor.size': linewidth,
                      'ytick.minor.size': linewidth,
                      'xtick.minor.width': linewidth/2,
                      'ytick.minor.width': linewidth/2,
                      'lines.linewidth': linewidth/2,
                      'savefig.transparent': True,
                      'figure.dpi': 300,
                      'figure.figsize': mm2in(60, 30),
                      'svg.fonttype': 'none',
                      'ps.fonttype': 42,
                      'pdf.fonttype': 42,
                  }, **override})
    
def set_paper(override=None):
    if override is None:
        override = dict()
    return _set_default("paper", override={**{
        'font.sans-serif': 'Liberation Sans',
    }, **override})
    
def set_talk(dark=False, **override):
    # Background color of latex beamer metropolis light theme
    if dark:
        bg_color = '#27363b'
        fg_color = '#fafafa'
    else:
        fg_color = '#27363b'
        bg_color = '#fafafa'
    return _set_default('talk', override={
        'font.sans-serif': 'Fira Sans',
        'text.color': fg_color,
        'axes.labelcolor': fg_color,
        'axes.titlecolor': fg_color,
        'axes.facecolor': bg_color,
        'axes.edgecolor': fg_color,
        'xtick.color': fg_color,
        'ytick.color': fg_color,
        'xtick.labelcolor': fg_color,
        'ytick.labelcolor': fg_color,
        'savefig.facecolor': bg_color,
        'figure.facecolor': bg_color,
        'figure.edgecolor': fg_color,
        'hatch.color': fg_color,
    })