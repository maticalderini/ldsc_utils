#!bin/bash
# Run via shh: dos2unix ldsc_3_bin_install.sh && ssh mcalde15@mcgill-cpu 'bash -s' < ldsc_3_bin_install.sh

##### Paths #####
base_dir=~/chronic_pain/SOFTWARE
conda_activate_path=~/miniconda3/bin/activate

ldsc_dir=${base_dir}/ldsc

ldsc_data_dir=${ldsc_dir}/data
phase3_dir=${ldsc_data_dir}/phase3

baseline_dir=${phase3_dir}/baseline

### Clone repo #####
cd ${base_dir}
if [ ! -d ${ldsc_dir} ]; then
  git clone https://github.com/bulik/ldsc.git
else
  echo "ldsc directory already exists"
fi

# Create conda environment
# source ${conda_activate_path}
# conda env create --file ${ldsc_dir}/environment.yml
# echo 'ldsc conda environement created, activate with "conda activate ldsc"'

### Get sample data #####
mkdir -p ${ldsc_data_dir}
cd ${ldsc_data_dir}
echo 'Downloading sample data'

base_url=https://alkesgroup.broadinstitute.org/LDSCORE
# Summary statistics
echo 'Downloading summary statistics'
sumstats=GIANT_BMI_Speliotes2010_publicrelease_HapMapCeuFreq.txt
if [ ! -f ${ldsc_data_dir}/${sumstats} ]; then
  wget http://portals.broadinstitute.org/collaboration/giant/images/b/b7/${sumstats}.gz && gunzip ${sumstats}.gz
else
  echo "BMI sumstats already in directory"
fi

# HapMap3 SNPs
echo 'Downloading hapmap3 snps'
hap3=w_hm3.snplist
if [ ! -f ${ldsc_data_dir}/${hap3} ]; then
  wget https://data.broadinstitute.org/alkesgroup/LDSCORE/${hap3}.bz2 && bzip2 -d ${hap3}.bz2
else
  echo "hapmap file already in directory"
fi

#### Phase 3 Files #####
# Baseline model LD scores
if [ ! -d ${phase3_dir} ]; then
  mkdir -p ${phase3_dir}
  cd ${phase3_dir}

  echo  '1. Downloading Baseline model LD scores'
  bsln_3=1000G_Phase3_baseline_v1.2_ldscores.tgz
  wget ${base_url}/${bsln_3} && tar -xvzf ${bsln_3} && rm ${bsln_3}
  # bsln_3=1000G_Phase3_baselineLD_v2.2_ldscores.tgz
  # wget ${base_url}/${bsln_3} && mkdir baseline && tar -xvzf ${bsln_3} -C baseline/ && rm ${bsln_3}

  # Regression weights
  echo  '2. Downloading regression weights'
  wgt_3=1000G_Phase3_weights_hm3_no_MHC
  wget ${base_url}/${wgt_3}.tgz && tar -xvzf ${wgt_3}.tgz && mv ${wgt_3} weights && rm ${wgt_3}.tgz

  # Allele frequencies
  echo  '3. Downloading allele frequencies'
  frq_3=1000G_Phase3_frq
  wget ${base_url}/${frq_3}.tgz && tar -xvzf ${frq_3}.tgz && mv ${frq_3} frequencies && rm ${frq_3}.tgz

  # Cell-type files
  echo  '4. Downloading Cell-type files'
  ctg_3=1000G_Phase3_cell_type_groups
  wget ${base_url}/${ctg_3}.tgz && tar -xvzf ${ctg_3}.tgz && mv ${ctg_3} cell_type_groups && rm ${ctg_3}.tgz

  echo '5. Downloading Plink files'
  plink_3=1000G_Phase3_plinkfiles.tgz
  wget ${base_url}/${plink_3} && tar -xvzf ${plink_3} && mv 1000G_EUR_Phase3_plink plink_files && rm ${plink_3}
else
  echo "Phase 3 directory already exists"
fi
