#%% Libraries
from pathlib import Path
import pandas as pd
import numpy as np
import shutil

#%% Functions
def main(annot_dir, prefix, save_dir=None):
    '''
    Assumes annot is any column not in ['CHR', 'BP', 'SNP', 'CM']
    assumes format: {prefix}.{chr_n}.{file_ext}
    Changes following files:
        *{chr_n}.annot.gz
        *{chr_n}.l2.ldscore.gz
    Copies followig files:
        *{chr_n}.l2.M
        *{chr_n}.l2.M_5_50
        *{chr_n}.log
    '''
    # Paths
    annot_dir = Path(annot_dir)
    save_dir = annot_dir.parent/f'bin_{annot_dir.name}' if save_dir is None else Path(save_dir)
    save_dir.mkdir(parents=True, exist_ok=True)
    
    # Non-file-specific parameters
    base_cols = ['CHR', 'BP', 'SNP', 'CM']
    
    # File iterations
    for annot_path in annot_dir.glob(f'{prefix}*.annot.gz'):
        print(f'> Currently processing {annot_path.name}')
        chr_n = annot_path.name.split('.')[1]
        
        # Annotation files
        print('\tLoading annot file')
        annot = pd.read_csv(annot_path, delim_whitespace=True)
        
        keep_cols = [col for col in annot if col not in base_cols and np.isin(annot[col].unique(), [0, 1]).all()]
        keep_cols =  base_cols + keep_cols
        print(f'\tDropping {len(annot.columns) - len(keep_cols)} annotations')
        annot = annot[keep_cols]
        
        print('\tSaving new annot file')
        annot.to_csv(save_dir/annot_path.name, sep='\t', index=False)
        
        
        # l2 files
        print('\tLoading l2.ldscore file')
        l2_name = f'{prefix}.{chr_n}.l2.ldscore.gz'
        l2 = pd.read_csv(annot_dir/l2_name, delim_whitespace=True)
        l2 = l2.loc[:, l2.columns.str[:-2].isin(keep_cols) | l2.columns.isin(base_cols)]
    
        print('\tSaving new l2 file')
        l2.to_csv(save_dir/l2_name, sep='\t', index=False)
    
    
        # Index for annotations to keep. Just annotations from base to the last one
        keep_ix = np.where(annot.columns[~annot.columns.isin(base_cols)].isin(keep_cols))[0]
        
        # M file
        print('\tLoading l2.M file')
        M_name = f'{prefix}.{chr_n}.l2.M'
        M = np.genfromtxt(annot_dir/M_name)[keep_ix]
    
        print('\tSaving new M file')
        np.savetxt(save_dir/M_name, M, delimiter='\t', newline='\t', fmt='%f')
    
        # M_5_50 files
        print('\tLoading l2.M_5_50')
        M550_name = f'{prefix}.{chr_n}.l2.M_5_50'
        M550 = np.genfromtxt(annot_dir/M550_name)[keep_ix]
        
        print('\tSaving new M_5_50 file')
        np.savetxt(save_dir/M550_name, M550, delimiter='\t', newline='\t', fmt='%f')
        
        
        print('\tCopying .log file')
        shutil.copy(annot_dir/f'{prefix}.{chr_n}.log', save_dir)
        
#%%  Main
if __name__ == '__main__':
    
    # Parameters
    # annot_dir = Path(r'C:\Users\USer1\Documents\Consulting\Mcgill\chronic_pain\data\baseline')
    annot_dir = '/home/mcb/users/mcalde15/chronic_pain/SOFTWARE/ldsc/data/phase3/baseline'
    prefix = 'baselineLD'

    # out = main(annot_dir, prefix)
    


