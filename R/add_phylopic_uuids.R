add_phylopic_uuids <- function(original_output) {
  uuid_table <- dbConnect(
    RSQLite::SQLite(), "/home/jarrod/R Scripts/get_phylopic_uuids/db/phylo_uuids.sqlite"
    ) %>%
    dbReadTable("phylopic_uuids")

  new_output <- left_join(original_output, uuid_table, by =
                                    c("image.lookup.text" = "string")) %>%
    select(-c("search_term")) %>%
    rename(phylopic.uid = uid)

  return(new_output)
}
