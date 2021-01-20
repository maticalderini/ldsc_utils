#!bin/bash

##### Paths #####
results_suffix=CP
results_dir=~/chronic_pain/data/${results_suffix}_ldsc_1_results
input_sumstats=/home/mcb/users/mcalde15/chronic_pain/data/raw/MCP_Eur_A21_ldsc_format.tsv

base_dir=~/chronic_pain/SOFTWARE
ldsc_dir=${base_dir}/ldsc
ldsc_data_dir=${ldsc_dir}/data
phase1_dir=${ldsc_data_dir}/phase1


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
#  --ref-ld-chr ${phase1_dir}/baseline/baseline.\
#  --w-ld-chr ${phase1_dir}/weights/weights.\
#  --overlap-annot\
#  --frqfile-chr ${phase1_dir}/frequencies/1000G.mac5eur.\
#  --out ${results_dir}/${results_suffix}_baseline


for filepath in ${phase1_dir}/cell_type_groups/*.1.annot*; do
  filename=$(basename "$filepath")
  cell_name="$(cut -d'.' -f1 <<<${filename})"
  echo ${cell_name}
  python ${ldsc_dir}/ldsc.py --h2 ${results_dir}/${results_suffix}.sumstats.gz\
   --w-ld-chr ${phase1_dir}/weights/weights.\
   --ref-ld-chr ${phase1_dir}/cell_type_groups/${cell_name}.,${phase1_dir}/baseline/baseline.\
   --overlap-annot\
   --frqfile-chr ${phase1_dir}/frequencies/1000G.mac5eur.\
   --out ${results_dir}/${results_suffix}_ctg_${cell_name}\
   --print-coefficients
done
