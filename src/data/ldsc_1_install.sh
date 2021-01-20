#!bin/bash

##### Paths #####
base_dir=~/chronic_pain/SOFTWARE
conda_activate_path=~/miniconda3/bin/activate

ldsc_dir=${base_dir}/ldsc
ldsc_data_dir=${ldsc_dir}/data
phase1_dir=${ldsc_data_dir}/phase1

base_url=https://alkesgroup.broadinstitute.org/LDSCORE

### Clone repo #####
cd ${base_dir}
if [ ! -d ${ldsc_dir} ]; then
  git clone https://github.com/bulik/ldsc.git
else
  echo "ldsc directory already exists"
fi

# Create conda environment
source ${conda_activate_path}
conda env create --file ${ldsc_dir}/environment.yml
echo 'ldsc conda environement created, activate with "conda activate ldsc"'

### Get sample data #####
# Download phase-independent files
mkdir -p ${ldsc_data_dir}
cd ${ldsc_data_dir}
echo 'Downloading sample data'

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

# ##### Phase 1 Files #####
if [ ! -d ${phase1_dir} ]; then
  mkdir -p ${phase1_dir}
  cd ${phase1_dir}

  echo  '1. Downloading Baseline model LD scores'
  bsln_1=1000G_Phase1_baseline_ldscores.tgz
  wget ${base_url}/${bsln_1} && tar -xvzf ${bsln_1} && rm ${bsln_1}

  # Regression weights
  echo  '2. Downloading regression weights'
  wgt_1=weights_hm3_no_hla
  wget ${base_url}/${wgt_1}.tgz && tar -xvzf ${wgt_1}.tgz && mv ${wgt_1} weights && rm ${wgt_1}.tgz

  # Allele frequencies
  echo  '3. Downloading allele frequencies'
  frq_1=1000G_Phase1_frq.tgz
  wget ${base_url}/${frq_1} && tar -xvzf ${frq_1} && mv 1000G_frq frequencies && rm ${frq_1}

  # Cell-type files
  echo  '4. Downloading Cell-type files'
  ctg_1=1000G_Phase1_cell_type_groups.tgz
  wget ${base_url}/${ctg_1} && tar -xvzf ${ctg_1} && rm ${ctg_1}

  # Plink files
  echo '5. Downloading Plink files'
  plink_1=1000G_Phase1_plinkfiles.tgz
  wget ${base_url}/${plink_1} && tar -xvzf ${plink_1} && mv 1000G_plinkfiles plink_files && rm ${plink_1}

else
  echo "Phase 1 directory already exists"
fi
