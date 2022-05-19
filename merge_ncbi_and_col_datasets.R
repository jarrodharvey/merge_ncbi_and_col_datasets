rm(list=ls())
cat("\014")

easypackages::packages("tibble", "magrittr", "dplyr", "stringr", "pbapply")

sapply(list.files("R", full.names = TRUE), source)

ncbi_species <- read.csv("/home/jarrod/R Scripts/get_ncbi_dmp/ncbi_species_list.csv")
col_species <- read.csv("/home/jarrod/scripts/darwin_core_archive_common_names/col_species_list.csv")

merged_species <- bind_rows(col_species, ncbi_species) %>%
  select(-c("X")) %>%
  mutate(across(.cols = everything(), trimws)) %>%
  mutate(across(.cols = everything(), str_to_sentence)) %>%
  distinct(across(-image.lookup.text), .keep_all = TRUE) %>%
  arrange(nchar(common.name))

# Abandoning this idea to disambiguate on scientific names
# will not look too good for laypeople, will just select a scientific name
# at random
# merged_species$search.term <- merged_species$common.name
#
# duplicate_common_names <- merged_species$common.name %>%
#   .[duplicated(.)]
#
# merged_species[
#   merged_species$common.name %in% duplicate_common_names,
#   ]$search.term <- paste0(
#     merged_species[
#       merged_species$common.name %in% duplicate_common_names,
#     ]$common.name,
#     " (",
#     merged_species[
#       merged_species$common.name %in% duplicate_common_names,
#     ]$scientific.name,
#     ")"
#   )

write.csv(merged_species, "species_table.csv")
