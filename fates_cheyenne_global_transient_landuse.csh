#!/usr/bin/env bash

SRCDIR=$HOME/ctsm
cd ${SRCDIR}
GITHASH1=`git log -n 1 --format=%h`
cd src/fates
GITHASH2=`git log -n 1 --format=%h`

SETUP_CASE=fates_clm50_global_4x5_historicaltransient_nofire
CASE_NAME=${SETUP_CASE}_${GITHASH1}_${GITHASH2}
basedir=$SRCDIR/cime/scripts

export RES=f45_f45_mg37
export CIME_MODEL=cesm
project=P93300041

#### load_machine_files
cd $basedir
./create_newcase -case ${CASE_NAME} -res ${RES} -compset HIST_DATM%GSWP3v1_CLM50%FATES_SICE_SOCN_MOSART_SGLC_SWAV -mach cheyenne -project ${project} --run-unsupported
#./create_newcase -case ${CASE_NAME} -res ${RES} -compset 1850_DATM%GSWP3v1_CLM50%FATES_SICE_SOCN_MOSART_SGLC_SWAV -mach cheyenne -project ${project} --run-unsupported
#./create_newcase -case ${CASE_NAME} -res ${RES} -compset I2000Clm50FatesGs -mach cheyenne -project ${project} --run-unsupported

cd ${CASE_NAME}

 ./xmlchange STOP_OPTION=nyears
 ./xmlchange STOP_N=10

# ./xmlchange REST_N=10
# ./xmlchange REST_OPTION=nyears
# #./xmlchange CONTINUE_RUN=FALSE
# ./xmlchange RESUBMIT=0
# #./xmlchange DEBUG=FALSE

# #./xmlchange DIN_LOC_ROOT=/glade/u/home/charlie/cesm_input_data

# # SET PATHS TO SCRATCH ROOT, DOMAIN AND MET DATA (USERS WILL PROB NOT CHANGE THESE)
# # =================================================================================

# ./xmlchange ATM_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
# ./xmlchange ATM_DOMAIN_PATH=${CLM_DOMAIN_DIR}
# ./xmlchange LND_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
# ./xmlchange LND_DOMAIN_PATH=${CLM_DOMAIN_DIR}
# ./xmlchange DATM_MODE=CLMGSWP3v1
# ./xmlchange CLM_USRDAT_NAME=${SITE_NAME}
# #./xmlchange DIN_LOC_ROOT_CLMFORC=${DIN_LOC_ROOT_FORCE}

# ./xmlchange DIN_LOC_ROOT_CLMFORC=/glade/p/cgd/tss/CTSM_datm_forcing_data

./xmlchange NTASKS_LND=288
./xmlchange NTASKS_CPL=288
./xmlchange NTASKS_ROF=288
./xmlchange NTASKS_ICE=288
./xmlchange NTASKS_OCN=288
./xmlchange NTASKS_GLC=288
./xmlchange NTASKS_WAV=288

# ./xmlchange EXEROOT=/glade/scratch/charlie/$CASE_NAME/bld
# ./xmlchange RUNDIR=/glade/scratch/charlie/$CASE_NAME/run
# ./xmlchange DOUT_S_ROOT=/glade/scratch/charlie/archive/$CASE_NAME

 ./xmlchange JOB_WALLCLOCK_TIME=5:59:00

# ### use the following for hybrid runs, e.g. if needed to turn fire on after its been off
# export YEAR_REST=0031
# export REF_CASE=fates_clm50_fullmodel_california_test4_lesstreesmoregrass_readlightning_pollyrevisedparams_modinitd_noshrub_c3grass_firethresh25_nofire_8de77cb1_e130fe39
# ./xmlchange RUN_TYPE=hybrid
# ./xmlchange RUN_REFDATE=${YEAR_REST}-01-01
# ./xmlchange RUN_REFCASE=${REF_CASE}
# #### copy restart files
# cp /glade/scratch/charlie/archive/${REF_CASE}/rest/${YEAR_REST}-01-01-00000/rpointer* /glade/scratch/charlie/$CASE_NAME/run
# cp /glade/scratch/charlie/archive/${REF_CASE}/rest/${YEAR_REST}-01-01-00000/${REF_CASE}*.nc /glade/scratch/charlie/$CASE_NAME/run

./xmlchange JOB_QUEUE=economy



cat > user_nl_clm <<EOF
fates_paramfile = '/glade/u/home/charlie/landuse_runscripts/mod_from_rosiefiles_6PFTs_distfrac0.5.nc'
hist_fincl1 = 'NPLANT_SCPF','M1_SCPF','M2_SCPF','M3_SCPF','M4_SCPF','M5_SCPF','M6_SCPF','M7_SCPF','M8_SCPF','PFTcrownarea','CROWNFIREMORT_SCPF','CAMBIALFIREMORT_SCPF','SCORCH_HEIGHT','BIOMASS_BY_AGE','NPLANT_CANOPY_SCPF','MORTALITY_CANOPY_SCPF','SECONDARY_FOREST_FRACTION','WOOD_PRODUCT','SECONDARY_FOREST_BIOMASS','SECONDARY_AREA_AGE_ANTHRO_DIST','SECONDARY_AREA_PATCH_AGE_DIST','PFTcanopycrownarea'
use_fates_spitfire = .false.
finidat='/glade/scratch/rfisher/archive/FBG_COMP_287ppm/rest/0180-01-01-00000/FBG_COMP_287ppm.clm2.r.0180-01-01-00000.nc'
use_fates_logging = .true.
use_fates_fixed_biogeog = .true.
fsurdat = '/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/release-clm5.0.18/surfdata_4x5_hist_16pfts_Irrig_CMIP6_simyr1850_c190214.nc'
flanduse_timeseries = '/glade/u/home/charlie/scratch/landuse.timeseries_4x5_hist_16pfts_Irrig_CMIP6_simyr1850-2015_c190214_cdkmod_areaharvest_c200622.nc'
EOF

./case.setup

qcmd -A ${project} -- ./case.build
./case.submit




