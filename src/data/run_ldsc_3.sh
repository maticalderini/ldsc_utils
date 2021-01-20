#!bin/bash

##### Paths #####
results_suffix=CP
results_dir=~/chronic_pain/data/${results_suffix}_ldsc_3_results
input_sumstats=/home/mcb/users/mcalde15/chronic_pain/data/raw/MCP_Eur_A21_ldsc_format.tsv

base_dir=~/chronic_pain/SOFTWARE
ldsc_dir=${base_dir}/ldsc
ldsc_data_dir=${ldsc_dir}/data
phase3_dir=${ldsc_data_dir}/phase3


conda_activate_path=~/miniconda3/bin/activate

source ${conda_activate_path}
conda activate ldsc

mkdir -p ${results_dir}

python ${ldsc_dir}/munge_sumstats.py\
 --sumstats ${input_sumstats}\
 --merge-alleles ${ldsc_data_dir}/w_hm3.snplist\
 --out ${results_dir}/${results_suffix}\
 --a1-inc\
 --chunksize 500000

# python ${ldsc_dir}/ldsc.py --h2 ${results_dir}/${results_suffix}.sumstats.gz\
#  --ref-ld-chr ${phase3_dir}/baseline/baselineLD.\
#  --w-ld-chr ${phase3_dir}/weights/weights.hm3_noMHC.\
#  --overlap-annot\
#  --frqfile-chr ${phase3_dir}/frequencies/1000G.EUR.QC.\
#  --out ${results_dir}/${results_suffix}_baseline
#
# { read -r;  while read -r  cell_num cell_name; do
#
#   cell_name=${cell_name%.bed}
#   echo ${cell_name}
#
#   python ${ldsc_dir}/ldsc.py --h2 ${results_dir}/${results_suffix}.sumstats.gz\
#    --w-ld-chr ${phase3_dir}/weights/weights.hm3_noMHC.\
#    --ref-ld-chr ${phase3_dir}/cell_type_groups/cell_type_group.${cell_num}.,${phase3_dir}/baseline/baselineLD.\
#    --overlap-annot\
#    --frqfile-chr ${phase3_dir}/frequencies/1000G.EUR.QC.\
#    --out ${results_dir}/${results_suffix}_ctg_${cell_name}\
#    --print-coefficients
#
# done; } < ${phase3_dir}/cell_type_groups/names
