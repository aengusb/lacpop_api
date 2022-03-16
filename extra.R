
# Working with SQL

- Not everything fits nicely into a datefame
- But most things fit nicely into dataframes!
  
  ```{r}
suppressMessages(library(RSQLite))

# Creates a db at the location you specify
api_db <- dbConnect(RSQLite::SQLite(), "api_db.db")

class(api_db); api_db
```


```{r}
# sqllite does not like periods in column names
colnames(bills)[10:11] <- c("description_fr","description_en")
dbWriteTable(api_db, "bills", bills, overwrite = TRUE)

# Get all columns
dbGetQuery(api_db, "SELECT * FROM bills")

# Add a limit to how many observations you get
dbGetQuery(api_db, "SELECT * FROM bills LIMIT 1")

# Select only certain columns
dbGetQuery(api_db, "SELECT session, result, yea_total, date FROM bills")
```


```{r}

# Again, sqllite does not like periods in column names
colnames(vote_details_df)[3:4] <- c("party_name_en","party_shortname_en")
dbWriteTable(api_db, "votes", vote_details_df, overwrite = TRUE)

# Check what was written
dbGetQuery(api_db, "SELECT * FROM votes LIMIT 1")

# More complicated query
dbGetQuery(api_db, 
           "SELECT bills.session, bills.result, bills.yea_total, bills.nay_total,
           bills.description_en AS description, votes.party_name_en, disagreement
           FROM bills 
           LEFT JOIN votes ON bills.url = votes.url 
           LIMIT 1")

```

## Activity 3

```{r}

# Write canada_submissions to your database

# Write reddit_comments to your database

# Use a LEFT JOIN query to get all comments for a particular submission 

```

## Using indexes

```{r}

time_taken <- function(command) {
  start <- Sys.time()
  output <- command
  print(Sys.time() - start)
  return(output)
}

sample_dat <- sample(c(1:100), size = 5000000, replace = TRUE) %>%
  data.frame(int = ., sqrt = sqrt(.))

# This takes a bit of space
RSQLite::dbWriteTable(api_db, "sample_dat", sample_dat, overwrite = TRUE)
```


```{r}
all_67s <- time_taken(dbGetQuery(api_db, "SELECT * FROM sample_dat WHERE int = 67"))

dbExecute(api_db, "CREATE INDEX index_sample ON sample_dat(int)")

all_67s <- time_taken(dbGetQuery(api_db, "SELECT * FROM sample_dat WHERE int = 67"))

```

# Other useful db commands

```{r}

# This cleans up the database - removes space occupied by deleted rows 
dbExecute(api_db, "VACUUM")

# This drops a table
dbExecute(api_db, "DROP TABLE sample_dat")

# These commands give a summary of all tables and indexes in your database
dbGetQuery(api_db, "SELECT * FROM sqlite_schema WHERE type='table'")
dbGetQuery(db.cemp, "SELECT * FROM sqlite_master WHERE type = 'index';")

```

