rm(list=ls())
cat("\014")

easypackages::packages("tibble", "magrittr", "dplyr", "stringr", "pbapply", "DBI", "RSQLite", "pluralize")

sapply(list.files("R", full.names = TRUE), source)

ncbi_species <- read.csv("/home/jarrod/R Scripts/get_ncbi_dmp/ncbi_species_list.csv")
col_species <- read.csv("/home/jarrod/scripts/darwin_core_archive_common_names/col_species_list.csv")

merged_species <- bind_rows(col_species, ncbi_species) %>%
  select(-c("X")) %>%
  mutate(across(.cols = everything(), trimws)) %>%
  mutate(across(.cols = everything(), str_to_sentence)) %>%
  distinct(across(-image.lookup.text), .keep_all = TRUE) %>%
  arrange(nchar(common.name))

unique_scientific_names_with_authorship <- unique(merged_species$image.lookup.text)

# The top six species can be cool/interesting ones to draw in the user
cool_lead_species <- read.csv("cool_top_species.csv")

# Some popular dinosaur species, as they are often known by scientific names
cool_dinosaurs <- read.csv("cool_dinosaurs.csv")

output <- bind_rows(cool_lead_species, merged_species, cool_dinosaurs) %>%
  update_output_with_ott_data(.) %>%
  # Apostrophes cause issues with db queries
  mutate(common.name = str_remove_all(.$common.name, "'"))

########OUTPUTTING BELOW##########

write.csv(output, "species_table.csv", row.names = FALSE)

saveRDS(unique(output$common.name), "unique_common_names.rds" )

saveRDS(unique_scientific_names_with_authorship, "unique_scientific_names_with_authorship.rds")

file.copy("unique_scientific_names_with_authorship.rds", "/home/jarrod/R Scripts/get_phylopic_uuids/data", overwrite = TRUE)

file.copy("unique_common_names.rds", "/home/jarrod/Dropbox/scripts/evolution-mapper/data/", overwrite = TRUE)

# I don't think the third column will actually be needed for image lookup... I'll remove it.

output$image.lookup.text <- NULL
names(output) <- c("ott", "common", "scientific")

mydb <- dbConnect(RSQLite::SQLite(), "species.sqlite")

dbWriteTable(mydb, "species", output, overwrite = TRUE)

dbDisconnect(mydb)

file.copy("species.sqlite", "/home/jarrod/Dropbox/scripts/evolution-mapper/data/", overwrite = TRUE)

file.copy("species_table.csv", "/home/jarrod/R Scripts/phylo_experimenting/data", overwrite = TRUE)
