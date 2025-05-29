
library(rvest)
library(stringr)
library(reticulate)

# Step 1: Input the URL for the AEA journal issue you want to read
initial_url <- "https://www.aeaweb.org/issues/801"

# Step 2: # Define paths
setwd("C:/Users/jmart/Downloads")

# Step 3: Do you want R to open the links to the articles from this issue in a web browser?
## Y = Yes, N = No
open_in_browser <- "Y"

# Step 4: Do you want to convert the text to mp3?
output_as_mp3 <- "Y"

# Step 5: set path of text to mp3 converter
ffmpeg_path <- "C:/ffmpeg/bin/ffmpeg.exe"

##### web scraping ######

# pull links
linkz <- read_html(initial_url) %>%
  html_nodes("a") %>% 
  html_attr("href") %>%
  .[grepl("/articles?", .)]

# loop web scrape
y <- list()
for(i in 1:length(linkz)){
  read_html(paste0("https://www.aeaweb.org/", linkz[i])) -> x
  
  if(i == 1){
    x %>%
      html_nodes(xpath = '/html/body/main/div/section/div[4]') %>%
      html_text() %>%
      str_replace_all("\\n", " ") %>%
      str_replace_all("\\t", " ") %>%
      str_replace_all(":", " ") %>%
      str_replace_all("\\.", " ") %>%
      str_replace_all(",", " ") %>%
      str_squish() -> issue
  }else{
    x %>%
      html_nodes(xpath = '/html/body/main/div/section/h1') %>%
      html_text() -> title
    
    x %>%
      html_nodes(xpath = '/html/body/main/div/section/ul') %>%
      html_text() %>%
      str_replace_all("\\n", " ") %>%
      str_replace_all("\\t", " ") %>%
      str_squish() -> authors
    
    x %>%
      html_nodes(xpath = '/html/body/main/div/section/div[4]/div[1]') %>%
      html_text() %>%
      trimws() -> journal
    
    x %>%
      html_nodes(xpath = '//*[@id="article-information"]/section[1]') %>%
      html_text() %>%
      str_replace_all("\\n", " ") %>%
      str_replace_all("\\t", " ") %>%
      str_squish() -> abstract
    
    y[[length(y)+1]] <- paste(title, authors, abstract) 
  }
  
  Sys.sleep(5)
}

##### open in browser #####

if(open_in_browser == "Y"){
  for(i in 3:(length(linkz))-1){
    browseURL(paste0("https://www.aeaweb.org/", linkz[i]))
    Sys.sleep(1)
  }
}

##### text to mp3 ####

# save output as mp3 or txt
if(output_as_mp3 == "N"){
  # save text
  writeLines(paste(unlist(y), collapse = ". "), con = paste0(name, ".txt"))
}else{
  gTTS <- import("gtts")
  tts <- gTTS$gTTS(paste(unlist(y), collapse = " "), lang = "en")
  tts$save("output.mp3")
  
  system(sprintf('"%s" -y -i output.mp3 -filter:a "atempo=2" "%s"', 
                 ffmpeg_path, 
                 paste0(issue, ".mp3")))
  file.remove("output.mp3")
}
