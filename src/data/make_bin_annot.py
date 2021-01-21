#%% Libraries
from pathlib import Path
import pandas as pd
import numpy as np

#%% Functions
def main(annot_dir, old_prefix, new_prefix='bin_'):
    '''
    Assumes annot is any column not in ['CHR', 'BP', 'SNP', 'CM']
    '''
    annot_dir = Path(annot_dir)
    base_cols = ['CHR', 'BP', 'SNP', 'CM']
    
    for filepath in annot_dir.glob(f'{old_prefix}*'):
        print(f'> Currently processing {filepath.name}')
        
        print('\tLoading annot file')
        annot = pd.read_csv(filepath, delim_whitespace=True)
        keep_cols = [col for col in annot if col not in base_cols and np.isin(annot[col].unique(), [0, 1]).all()]
        keep_cols =  base_cols + keep_cols
        print(f'\tDropping {len(annot.columns) - len(keep_cols)} annotations')
        annot = annot[keep_cols]
        
        new_name = new_prefix + filepath.name
        print('\tSaving new annot file')
        annot.to_csv(annot_dir/new_name, sep='\t', index=False)
        
#%%  Main
if __name__ == '__main__':
    
    annot_dir = r'C:\Users\USer1\Documents\Consulting\Mcgill\chronic_pain\data\raw\phase3\baseline'
    old_prefix = 'baselineLD.'
    new_prefix = 'bin_'

    main(annot_dir, old_prefix, new_prefix)
#%% Main

        

    
