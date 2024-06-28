
library(rvest)
library(stringr)

# Step 1: Input the URL for the AEA journal issue you want to read
initial_url <- "https://www.aeaweb.org/issues/767"

# Step 2: Change the working directory for where you want the text file placed
setwd("C:/Users/jmart/Downloads")

# Step 3: Do you want R to open the links to the articles from this issue in a web browser?
## Y = Yes, N = No
open_in_browser <- "Y/N"

##### code ######

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

# save text
writeLines(unlist(y), con = paste0(issue, ".txt"))

# open in browser
if(open_in_browser == "Y"){
  for(i in 2:length(linkz)){
    browseURL(paste0("https://www.aeaweb.org/", linkz[i]))
    Sys.sleep(3)
  }
}