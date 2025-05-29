
library(RSelenium)
library(rvest)
library(httr)
library(reticulate)
library(stringr)

# Step 1: Start the RSelenium server
rD <- rsDriver(browser = "firefox", port = 4544L, verbose = FALSE)
remDr <- rD$client

# Step 2: Input the URL for the science direct issue you want to read
remDr$navigate("https://www.sciencedirect.com/journal/journal-of-urban-economics/vol/147/")
Sys.sleep(5)

# Step 4: Change the working directory for where you want the text file placed
setwd("C:/Users/jmart/Downloads")

# Step 5: Do you want R to open the links to the articles from this issue in a web browser?
## Y = Yes, N = No
open_in_browser <- "Y"

# Step 6: Do you want to convert the text to mp3?
output_as_mp3 <- "Y"

##### code ######

# Extract the page source
page_source <- remDr$getPageSource()[[1]]

# Extract issue information
issue <- paste(read_html(page_source) %>% html_nodes("#journal-title") %>% html_text(), 
               read_html(page_source) %>% html_nodes(".js-vol-issue") %>% html_text(), 
               read_html(page_source) %>% html_nodes(".js-issue-status") %>% html_text())

# Parse the HTML and extract links
linkz <- read_html(page_source) %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("/article", .)] %>%
  .[!grepl(".pdf", .)]
linkz <- unique(linkz)

# loop web scrape
y <- list()
for(i in 1:length(linkz)){
  remDr$navigate(paste0("https://www.sciencedirect.com", linkz[i]))
  Sys.sleep(5)
  page_source <- remDr$getPageSource()[[1]]
  page_html <- read_html(page_source)
  
  title <- page_html %>%
    html_nodes(".title-text") %>%
    html_text(trim = TRUE) %>%
    str_replace_all("\\n", " ") %>%
    str_replace_all("\\t", " ") %>%
    str_replace_all(":", " ") %>%
    str_replace_all("\\.", " ") %>%
    str_replace_all(",", " ")
  
  authors <- page_html %>%
    html_nodes(".author-group") %>%
    html_text(trim = TRUE) %>%
    str_replace_all("\\n", " ") %>%
    str_replace_all("\\t", " ") %>%
    str_replace_all(":", " ") %>%
    str_replace_all("\\.", " ") %>%
    str_replace_all(",", " ") %>%
    gsub("Author links open overlay panel", "", .) %>%
    gsub("[0-9]", "", .) %>%
    str_squish()
  
  abstract <- page_html %>%
    html_nodes(".abstract.author") %>%
    html_text(trim = TRUE) %>%
    str_replace_all("\\n", " ") %>%
    str_replace_all("\\t", " ") %>%
    str_replace_all(":", " ") %>%
    str_replace_all("\\.", " ") %>%
    str_replace_all(",", " ") %>%
    str_squish() %>%
    gsub("Abstract", "", .) %>%
    .[1]
  
  abstract <- gsub("\\s*\\(JEL.*\\)$", "", abstract)
  
  if(length(title) > 0 & length(authors) > 0 & !is.na(abstract)){
    y[[length(y)+1]] <-  paste(title, authors, abstract)
  }
  
}
remDr$close()
rD$server$stop()

# open in browser
if(open_in_browser == "Y"){
  for(i in 1:length(linkz)){
    browseURL(paste0("https://www.sciencedirect.com", linkz[i]))
    Sys.sleep(1)
  }
}

# save output as mp3 or txt
if(output_as_mp3 == "N"){
  # save text
  writeLines(paste(unlist(y), collapse = ". "), con = paste0(issue, ".txt"))
}else{
  gTTS <- import("gtts")
  tts <- gTTS$gTTS(paste(unlist(y), collapse = " "), lang = "en")
  tts$save("output.mp3")
  
  ffmpeg_path <- "C:/ffmpeg/bin/ffmpeg.exe"
  system(sprintf('"%s" -y -i output.mp3 -filter:a "atempo=2" "%s"', 
                 ffmpeg_path, 
                 paste0(issue, ".mp3")))
  file.remove("output.mp3")
}