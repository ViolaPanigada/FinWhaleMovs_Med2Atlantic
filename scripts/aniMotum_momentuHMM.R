# ==============================================================================
# Behavioral-state analysis of Mediterranean fin whales
#
# Satellite telemetry data are filtered and regularised using a state-space 
# model with a correlated random walk (CRW) in aniMotum.
# Behavioral states are subsequently estimated using a two-state hidden
# Markov model (HMM) in momentuHMM.
#
# Raw telemetry data are not included in this repository.
# See the associated manuscript for the data availability statement.
#
# Required input columns:
#   id, date, lc, lon, lat, smaj, smin, eor
# ==============================================================================


# Load packages ----------------------------------------------------------------

library(aniMotum)
library(momentuHMM)
library(dplyr)
library(ggplot2)


# Import data ------------------------------------------------------------------

Denia_Tracks <- read.csv("Denia_Tracks.csv")

tag_data <- Denia_Tracks


# Prepare data -----------------------------------------------------------------

# Convert date to POSIXct (UTC)
tag_data$date <- as.POSIXct(
  tag_data$date,
  format = "%Y-%m-%d %H:%M:%S",
  tz = "UTC"
)

# Sort locations by individual and date
tag_data <- tag_data %>%
  arrange(id, date)

# Remove Argos location class Z and records with missing location class
tag_data <- tag_data %>%
  filter(
    !is.na(lc),
    lc != "",
    lc != "Z"
  )

# Visual quality control
ggplot(tag_data, aes(lon,lat)) +
  geom_point(size = 0.5) +
  facet_wrap(~id)


# Remove erroneous locations identified during visual data quality control
tag_data <- tag_data %>%
  filter(
    !(id == "221087" & lon > 10),
    !(id == "285963" & lon < -20),
    !(id == "215003" & lon < -20)
  )


# ==============================================================================
# Correlated random walk state-space model
# ==============================================================================

# Fit a correlated random walk state-space model and predict locations at
# regular 4-h intervals. A conservative maximum travel speed of 7 m/s is used
# during prefiltering.

fitcrw_4h <- fit_ssm(
  tag_data,
  model = "crw",
  time.step = 4,
  vmax = 7,
  control = ssm_control(
    verbose = 1,
    se = FALSE
  )
)


# Print SSM summary
summary(fitcrw_4h)


# ==============================================================================
# Prepare regularised locations for momentuHMM
# ==============================================================================

# Extract predicted locations from the CRW SSM
pred_forHMM <- grab(
  fitcrw_4h,
  what = "predicted",
  as_sf = FALSE
)

# Retain ID, time, longitude, and latitude
data_reg_forHMM <- as.data.frame(pred_forHMM[, 1:4])

colnames(data_reg_forHMM)[1:2] <- c(
  "ID",
  "time"
)


# Calculate step lengths and turning angles
data_forHMM <- prepData(
  data = data_reg_forHMM,
  type = "LL",
  coordNames = c("lon", "lat")
)


# ==============================================================================
# Two-state hidden Markov model
# ==============================================================================

# Observation distributions:
#   step length    = gamma
#   turning angle  = von Mises

dist <- list(
  step = "gamma",
  angle = "vm"
)

stateNames <- c(
  "ARS",
  "Transit"
)


# Fit the HMM using multiple sets of starting values ----------------------------

# Set seed to make generation of starting values reproducible
set.seed(12345)

# Number of fits with different starting values
niter <- 40

# Store fitted models
allmodels <- vector(
  mode = "list",
  length = niter
)


for (i in 1:niter) {
  
  # Starting values for step-length means
  stepMean0 <- runif(
    2,
    min = c(0.05, 10),
    max = c(20, 40)
  )
  
  # Starting values for step-length standard deviations
  stepSD0 <- runif(
    2,
    min = c(0.05, 10),
    max = c(20, 40)
  )
  
  # Starting values for turning-angle concentrations
  angleCon0 <- runif(
    2,
    min = c(0.01, 0.2),
    max = c(1, 3)
  )
  
  # Fit two-state HMM
  allmodels[[i]] <- fitHMM(
    data = data_forHMM,
    nbStates = 2,
    dist = dist,
    Par0 = list(
      step = c(stepMean0, stepSD0),
      angle = angleCon0
    ),
    stateNames = stateNames
  )
}


# Select best-fitting HMM -------------------------------------------------------

# Extract negative log-likelihood from each fitted model
allnegloglk <- sapply(
  allmodels,
  function(m) m$mod$minimum
)

# Identify model with the lowest negative log-likelihood
whichbest <- which.min(allnegloglk)

# Retain best-fitting model
hmm_4h <- allmodels[[whichbest]]


# Print final HMM
hmm_4h


# ==============================================================================
# Behavioural-state estimates
# ==============================================================================

# Obtain the most likely sequence of behavioural states using the
# Viterbi algorithm

data_forHMM$state_2st <- factor(
  viterbi(hmm_4h),
  levels = c(1, 2),
  labels = stateNames
)


# Calculate state probabilities
StateProbs <- stateProbs(hmm_4h)

data_forHMM$prob_ARS <- StateProbs[, 1]
data_forHMM$prob_Transit <- StateProbs[, 2]


# Calculate percentage of time spent in each state by individual
timeInStates(
  hmm_4h,
  by = "ID"
)


# ==============================================================================
# Export results
# ==============================================================================

write.csv(
  data_forHMM,
  "HMM_ts4h.csv",
  row.names = FALSE
)

