update_output_with_ott_data <- function(current_output) {
  # Some flags indicate that the the open TOL won't work with that species
  bad_flags <- read.csv("bad_flags.csv") %>%
    .$flag.name %>%
    paste(collapse = "|") %>%
    paste0("(", ., ")")

  ott_db <- dbConnect(RSQLite::SQLite(), "/home/jarrod/R Scripts/get_ott_data/db/species_with_otts.sqlite")
  ott_data <- dbReadTable(ott_db, "ott_data")

  current_output <- mutate(current_output, scientific.name = str_to_lower(current_output$scientific.name))

  joined <- left_join(current_output, ott_data, by = c("scientific.name" = "search_string")) %>%
    distinct(.) %>%
    filter(!grepl(bad_flags, .$flags))

  new_output <- joined

  new_output$scientific.name <- new_output$unique_name

  new_output <- select(new_output, c("ott_id", "common.name", "scientific.name")) %>%
    filter(!is.na(.$scientific.name))

  dbDisconnect(ott_db)

  return(new_output)
}
