#%% Libraries
from pathlib import Path

import pandas as pd

import numpy as np
from scipy.stats import norm
from scipy.stats import rankdata

import re

import matplotlib.pyplot as plt

#%% Functions
def man_plot(z=None, p=None, ax=None, **kwargs):
    '''Todo:
            - Add functionality for color for different chromosomes
    '''
    if ax is None: ax = plt.gca()
    assert z is not None or p is not None, 'One of z or p must be provided'
    
    
    p = norm.sf(np.abs(z))*2 if p is None else p
    log10p = -np.log10(p)
    
    ax.plot(log10p, '.', zorder=0)
    ax.hlines(-np.log10(5e-8), 0, len(log10p), ls='dashed', zorder=1)
    return(ax)

def fdr(p_vals):
    '''Calculates q-value from p-values'''
    ranked_p_values = rankdata(p_vals)
    fdr = p_vals * len(p_vals) / ranked_p_values
    fdr[fdr > 1] = 1
    return(fdr)

def plot_ldsc_results(df, axes, label_col='Category', sig='q',
                      prop_snps_col='Prop._SNPs', prop_h2_col='Prop._h2', enrch_col='Enrichment',
                      sig_color='forestgreen', nonsig_color='royalblue'):
    
    
    assert sig == 'q' or sig == 'p', 'sig must be "q" or "p"'
    
    df[f'{enrch_col}_log10p'] = -np.log10(df[f'{enrch_col}_p'])
    df['qval'] = fdr(df[f'{enrch_col}_p'])
    df['qval_log10'] = -np.log10(df['qval'])
    
    
    df = df.sort_values(by=f'{enrch_col}_log10p' if sig == 'p' else 'qval_log10').reset_index(drop=True).dropna()
    df['sig'] = df[f'{enrch_col}_log10p'] > -np.log10(0.05) if sig == 'p' else df['qval_log10'] > -np.log10(0.05)
    
    df_sig = df[df['sig'] == 1]
    df_notsig = df[df['sig'] == 0]
            
    colors = (nonsig_color, sig_color)
    for sub_df, color in zip((df_notsig, df_sig), colors):
        axes[0].barh(sub_df.index, sub_df[prop_snps_col], color=color)
        
        axes[1].barh(sub_df.index, sub_df[prop_h2_col],
                     xerr=sub_df[f'{prop_h2_col}_std_error'], color=color)
        
        axes[2].barh(sub_df.index, sub_df[enrch_col],
                     xerr=sub_df[f'{enrch_col}_std_error'], color=color)
        axes[3].barh(sub_df.index, sub_df[f'{enrch_col}_log10p'], color=color)
        axes[4].barh(sub_df.index, sub_df['qval_log10'], color=color)
    
            
    Y = range(len(df))
    ylim = (-1, max(Y) + 1)
    
    axes[0].set(title='Proportion of SNPs',
                yticks=Y, yticklabels=df[label_col], ylim=ylim)
    for ax, title in zip(axes[1:],
                         ('Proportion of h2', 'Enrichment', r'Significance ($log_{10}(p)$)', r'Significance ($log_{10}(q)$)')):
        ax.set(title=title, yticks=Y, yticklabels=[], ylim=ylim)
    
    axes[-1].vlines(-np.log10(0.05), *ylim, ls='--')
    
    [lab.set_color(sig_color if i in df_sig.index.to_list() else nonsig_color) for i, lab in enumerate(axes[0].get_yticklabels())]



def main(data_dir, results_prefix, save_dir=None):
    # Preliminary
    data_dir = Path(data_dir)
    save_dir = data_dir/f'{results_prefix}_post_proc' if save_dir is None else Path(save_dir)
    save_dir.mkdir(parents=True, exist_ok=True)
    
    # Summary stats
    sumstat = pd.read_csv(data_dir/f'{results_prefix}.sumstats.gz', delim_whitespace=True)
    
    sumstat_clean = sumstat.dropna().reset_index(drop=True)
    sumstat_clean['p'] = norm.sf(abs(sumstat_clean['Z'])*2)
    sumstat_clean.to_csv(save_dir/f'{results_prefix}.sumstats_clean.gz', index=False, sep='\t')
    
    fig, ax = plt.subplots(figsize=(20, 5))
    man_plot(z=sumstat_clean.Z, ax=ax)
    ax.set(title='Summary Statistics')
    fig.savefig(save_dir/f'{results_prefix}_sumstats')
    
    # Baseline annots
    baseline = pd.read_csv(data_dir/f'{results_prefix}_baseline.results', delim_whitespace=True)
    baseline['Category'] = baseline['Category'].str[:-2]
    
    n_plots = 5
    fig, axes = plt.subplots(1, n_plots, figsize=(n_plots*7, len(baseline)/4))
    plot_ldsc_results(baseline, axes)
    plt.tight_layout()
    fig.savefig(save_dir/f'{results_prefix}_baseline')

    # Cell-type  
    ctgs = pd.concat([pd.read_csv(file, delim_whitespace=True).assign(ctg=re.search(f'{results_prefix}_ctg_(.*).results', file.name).group(1)) for file in data_dir.glob(f'{results_prefix}_ctg_*.results')])
    ctgs['Category'] = ctgs['Category'].str[:-2]
    
    ctgs = ctgs[~ctgs.Category.isin(baseline.Category)].reset_index(drop=True)
    
    # ctgs.to_csv(save_dir/f'{results_prefix}_ctgs.csv', index=False)
    
    n_plots = 5
    fig, axes = plt.subplots(1, n_plots, figsize=(n_plots*7, len(baseline)/4))
    plot_ldsc_results(ctgs, axes, label_col='ctg')
    plt.tight_layout()
    fig.savefig(save_dir/f'{results_prefix}_ctgs')
    
#%% Main
if __name__ == '__main__':
    data_dir = r'C:\Users\USer1\Documents\Consulting\Mcgill\chronic_pain\newest_results'
    results_prefix = 'CP'
    
    main(data_dir, results_prefix)
    

