library(tidyverse)
library(readxl)
library(lubridate)
library(edwr)

clev <- read_excel("data/raw/patients.xlsx",
                   sheet = "Clevidipine Pts",
                   col_types = "text",
                   col_names = "fin",
                   skip = 1)
nic <- read_excel("data/raw/patients.xlsx",
                  sheet = "Nicardipine Pts",
                  col_types = "text",
                  col_names = "fin",
                  skip = 1)

fins <- bind_rows(clev, nic)

fins_mbo <- concat_encounters(fins$fin)

# run MBO query:
#   * Identifiers
#       - Financial Number: fins_mbo

pts_id <- read_data("data/raw", "identifiers_2017", FALSE) %>%
    as.id()

pts_mbo <- concat_encounters(pts_id$millennium.id)

# run MBO queries:
#   * Encounters
#   * Medications - Inpatient - Prompt
#       - Medication (Generic): niCARdipine;clevidipine

# encounters <- read_data("data/raw", "encounters", FALSE) %>%
#     as.encounters()

bags <- read_data("data/raw", "meds", FALSE) %>%
    as.meds_inpt() %>%
    group_by(millennium.id) %>%
    filter(event.tag == "Begin Bag",
           med.datetime <= first(med.datetime) + hours(24)) %>%
    count(millennium.id, med)

write_rds(bags, "data/tidy/meds.Rds", "gz")

# cdm: nicardipine 40/200 - 66010602
# nicardipine 20/200 - 66190102
