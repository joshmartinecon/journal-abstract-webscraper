
rm(list=ls())
library(RSelenium)
library(rvest)
library(httr)
library(reticulate)
library(stringr)

# Define paths
downloads_path <- "C:/Users/jmart/Downloads"
setwd(downloads_path)

# Step 1: Start the RSelenium server
rD <- rsDriver(browser = "firefox", port = 4545L, verbose = FALSE, check = FALSE)
remDr <- rD$client

# Step 2: Input the URL for the QJE issue you want to read
initial_url <- "https://link.springer.com/journal/11150/volumes-and-issues/23-2"
remDr$navigate(initial_url)
Sys.sleep(5)

# Step 3: Put the abbreviation of the journal title
abbreviation <- "REHO"

# Step 4: Change the working directory for where you want the text file placed
setwd("C:/Users/jmart/Downloads")

# Step 5: Do you want R to open the links to the articles from this issue in a web browser?
## Y = Yes, N = No
open_in_browser <- "Y"

##### web scrape ######

# Extract the page source
page_source <- remDr$getPageSource()[[1]]

# Parse the HTML and extract links
linkz <- read_html(page_source) %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("/article/", .)]
linkz <- unique(linkz)

# loop web scrape
y <- list()
for(i in 1:length(linkz)){
  remDr$navigate(linkz[i])
  Sys.sleep(5)
  page_source <- remDr$getPageSource()[[1]]
  page_html <- read_html(page_source)
  
  title <- page_html %>%
    html_nodes(".c-article-title") %>%
    html_text(trim = TRUE)
  
  authors <- page_html %>%
    html_nodes(".c-article-author-list") %>%
    html_text(trim = TRUE) %>%
    str_replace_all("\\n", " ") %>%
    str_replace_all("\\t", " ") %>%
    str_replace_all(":", " ") %>%
    str_replace_all("\\.", " ") %>%
    str_replace_all(",", " ") %>%
    str_replace_all("\\d", " ") %>%
    str_squish()
  
  abstract <- page_html %>%
    html_nodes(".c-article-section") %>%
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

##### text to mp3 #####

gTTS <- import("gtts")
tts <- gTTS$gTTS(paste(unlist(y), collapse = " "), lang = "en")
tts$save("output.mp3")

ffmpeg_path <- "C:/ffmpeg/bin/ffmpeg.exe"
system(sprintf('"%s" -y -i output.mp3 -filter:a "atempo=2" "%s"', 
               ffmpeg_path, 
               paste0(abbreviation, " ", Sys.Date(), ".mp3")))
file.remove("output.mp3")

##### open in browser #####

if(open_in_browser == "Y"){
  for(i in 1:length(linkz)){
    browseURL(linkz[i])
    Sys.sleep(1)
  }
}
