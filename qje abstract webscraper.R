rm(list=ls())
library(RSelenium)
library(rvest)

# Step 1: Start the RSelenium server
rD <- rsDriver(browser = "firefox", port = 4545L, verbose = FALSE)
remDr <- rD$client

# Step 2: Input the URL for the QJE issue you want to read
initial_url <- "https://academic.oup.com/qje/issue/139/3"
remDr$navigate(initial_url)

# Step 3: prove you're not a robot!

# Step 4: Change the working directory for where you want the text file placed
setwd("C:/Users/jmart/Downloads")

# Step 5: Do you want R to open the links to the articles from this issue in a web browser?
## Y = Yes, N = No
open_in_browser <- "Y/N"

##### code ######

# Extract the page source
page_source <- remDr$getPageSource()[[1]]

# Parse the HTML and extract links
linkz <- read_html(page_source) %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("/articles?", .)] %>%
  .[!grepl("supplementary", .)]
linkz <- unique(linkz)

# loop web scrape
y <- list()
for(i in 1:length(linkz)){
  remDr$navigate(paste0("https://academic.oup.com", linkz[i]))
  Sys.sleep(5)
  page_source <- remDr$getPageSource()[[1]]
  page_html <- read_html(page_source)
  
  title <- page_html %>%
    html_nodes(".title-wrap") %>%
    html_text(trim = TRUE)
  
  authors <- page_html %>%
    html_nodes(".wi-authors") %>%
    html_text(trim = TRUE) %>%
    str_replace_all("\\n", " ") %>%
    str_replace_all("\\t", " ") %>%
    str_replace_all(":", " ") %>%
    str_replace_all("\\.", " ") %>%
    str_replace_all(",", " ") %>%
    str_squish() %>%
    gsub(" Search for other works by this author on Oxford Academic Google Scholar", "", .)
  
  abstract <- page_html %>%
    html_nodes(".chapter-para") %>%
    html_text(trim = TRUE) %>%
    str_replace_all("\\n", " ") %>%
    str_replace_all("\\t", " ") %>%
    str_replace_all(":", " ") %>%
    str_replace_all("\\.", " ") %>%
    str_replace_all(",", " ") %>%
    str_squish() %>%
    .[1]
    
    y[[length(y)+1]] <- paste(title, authors, abstract) 
  }
remDr$close()
rD$server$stop()

# save text
writeLines(unlist(y), con = paste0("QJE ",
  gsub("/", ".", gsub("https://academic.oup.com/qje/issue/", "", initial_url)), 
  ".txt"))

# open in browser
if(open_in_browser == "Y"){
  for(i in 1:length(linkz)){
    browseURL(paste0("https://academic.oup.com", linkz[i]))
    Sys.sleep(3)
  }
}