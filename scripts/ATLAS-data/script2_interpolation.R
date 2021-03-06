#     script2_interpolation.R Interpolate outputs from script1_index_calculation.R
#     for Atlas Product Reproducibility.
#
#     Copyright (C) 2020 Santander Meteorology Group (http://www.meteo.unican.es)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.


# This script uses bash interpolation scripts:
# https://github.com/SantanderMetGroup/ATLAS/tree/mai-devel/SOD-scripts

# The interpolation followed is the one used in EURO-CORDEX
# It is a Conservative Remapping procedure in which parameters sensitive to land-sea transitions
# are dually interpolated, i.e. land-sea separated, and then re-combined in one file.
# Residual missing values (NAs) in the interior domain are filled with values from a straighforward remap.
# Land fraction thresholds used were > 0.999 and < 0.001 for land and sea respectively.
# The interpolation bash scripts are available at https://github.com/SantanderMetGroup/ATLAS/tree/mai-devel/SOD-scripts/bash-interpolation-scripts

# Misc utilities for remote repo interaction:
library(devtools)

# USER PARAMETER SETTING -------------------------------------------------------

# Path to the bash script performing the interpolation (AtlasCDOremappeR_CMIP.sh), downloable from https://github.com/SantanderMetGroup/ATLAS/tree/mai-devel/SOD-scripts/bash-interpolation-scripts: 
script <- "AtlasCDOremappeR_CMIP.sh"  # supposing the bash script is in the current directory
# Path to the directory containing the NetCDFs to be interpolated, e.g. the current directory:
source.dir <- getwd()
# Path to the output directory, e.g.:
out.dir <- getwd()
# Path to the NetCDFs of the original masks (variable sftlf), e.g.:
mask.dir <- paste0(getwd(), "/masks")
# Path to the destination mask (land_sea_mask_2degree.nc4), downloable from https://github.com/SantanderMetGroup/ATLAS/tree/master/reference-grids:
refmask = paste0(mask.dir, "/land_sea_mask_2degree.nc4")

# INTERPOLATION ----------------------------------------------------------------

# List of nectcdf files containing the land/sea masks of each model
orig.masks <- list.files(mask.dir, full.names = TRUE)
gridsdir <- list.files(source.dir, pattern = "nc4", full.names = TRUE)
grids <- list.files(source.dir, pattern = "nc4")

# The loop iterates over models and performs the Conservative Remapping described above,
# writing the interpolated files in the output directory (out.dir):

for (m in 1:length(grids)) {
  grid <- grids[m]
  griddir <- gridsdir[m]
  model <- strsplit(grid, "_")[[1]][2]
  gridmask <- orig.masks[grep(model, orig.masks)]
  out.dir <- gsub("/raw/", "/cdo/", gsub(grid, "", griddir))
  if (!dir.exists(out.dir)) dir.create(out.dir, recursive = TRUE)
  if (!file.exists(paste0(out.dir, "/", grid))) {
    if (length(gridmask) > 0) {
      print(paste0(out.dir, "/", grid))
      system(paste("bash", script, griddir, paste0(out.dir, "/", grid), gridmask, refmask))
    } else {
      print(paste0(out.dir, "/", grid))
      system(paste0("cdo remapcon,", refmask, " ", griddir, " ", paste0(out.dir, "/", grid)))
    }
  }
}
# END
