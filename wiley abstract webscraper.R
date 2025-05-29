
rm(list=ls())
library(rvest)
library(httr)
library(reticulate)
library(RSelenium)

# Step 1: Input the URL for the issue you want to read
initial_url <- "https://onlinelibrary.wiley.com/toc/23258012/2025/91/4"

# Step 2: Put the abbreviation of the journal title (for name of .txt file)
abbreviation <- "SEJ"

# Step 3: Change the working directory for where you want to store output
setwd("C:/Users/jmart/Downloads")

# Step 4: Do you want R to open the links to the articles from this issue in a web browser?
## Y = Yes, N = No
open_in_browser <- "Y"

# Step 5: Do you want the output as an mp3 file instead?
## if so, make sure that you have python installed and have 'gtts' installed
## I speed up the mp3 by using ffmpeg downloadable from https://www.gyan.dev/ffmpeg/builds/
output_as_mp3 <- "Y"

##### code ######

# Parse the HTML and extract links
## may have to run this again if you hit a 403 error
# Start RSelenium
rD <- rsDriver(browser = "firefox", port = 4567L, verbose = FALSE)
remDr <- rD$client

# Go to the URL
remDr$navigate("https://onlinelibrary.wiley.com/toc/23258012/2025/91/4")

# Get page source after JS has rendered
page_source <- remDr$getPageSource()[[1]]
html <- read_html(page_source)

# Extract links
linkz <- html %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("/doi/", .)]
linkz <- unique(linkz)
linkz <- linkz[!grepl("https|/full/|#reference|/epdf/|/abs/", linkz)]
linkz <- paste0(paste0(strsplit(initial_url, "\\.com")[[1]][1], ".com"), linkz)
remDr$close()
rD$server$stop()

# loop web scrape
y <- list()
max_retries <- 5
for(i in 1:length(linkz)){
  
  retry_count <- 0
  success <- FALSE
  
  while (retry_count < max_retries && !success) {
    response <- GET(linkz[i], user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)"))
    
    if (!http_error(response)) {
      success <- TRUE  # Successful retrieval
    } else {
      retry_count <- retry_count + 1
      warning(paste("Failed to retrieve:", linkz[i], 
                    "- Attempt", retry_count, "of", max_retries))
      Sys.sleep(5)
    }
  }
  
  if (!success) {
    warning(paste("Skipping URL after", max_retries, "failed attempts:", linkz[i]))
    next
  }
  
  page_html <- read_html(response)
  
  title <- page_html %>%
    html_node("h1.citation__title") %>%
    html_text(trim = TRUE)
  
  authors <- page_html %>%
    html_nodes("div.loa-wrapper.loa-authors.hidden-xs.desktop-authors a.author-name.accordion-tabbed__control span") %>%
    html_text(trim = TRUE)
  
  abstract <- page_html %>%
    html_node("div.article-section__content.en.main p") %>%
    html_text(trim = TRUE)
  
  if(is.na(abstract)){
    next
  }
  
  y[[length(y) + 1]] <- paste(title, "... Authors:", paste(authors, collapse = " and "), "...", abstract)
  
  Sys.sleep(5)
  
  cat(paste0(round(i / length(linkz) * 100, 1), "% complete"), "\r")
}

# open in browser
if(open_in_browser == "Y"){
  for(i in 1:length(linkz)){
    browseURL(linkz[i])
    Sys.sleep(1)
  }
}

# save output as mp3 or txt
if(output_as_mp3 == "N"){
  # save text
  writeLines(unlist(y), con = paste0(abbreviation, " ", Sys.Date(), ".txt"))
}else{
  gTTS <- import("gtts")
  tts <- gTTS$gTTS(paste(unlist(y), collapse = " "), lang = "en")
  tts$save("output.mp3")
  
  ffmpeg_path <- "C:/ffmpeg/bin/ffmpeg.exe"
  system(sprintf('"%s" -y -i output.mp3 -filter:a "atempo=2" "%s"', 
                 ffmpeg_path, 
                 paste0(abbreviation, " ", Sys.Date(), ".mp3")))
  file.remove("output.mp3")
}