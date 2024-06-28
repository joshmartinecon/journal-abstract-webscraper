# The Issue

  - I read a lot for work 
  - I am time constrained
  - I am dyslexic
  
Converting the text from newly released academic papers to audio helps solve all of these issues for me.

# The Solution

I've attached some code in R that I use to web scrape the text of the titles, authors and abstracts from issues that have recently been published in AEA journals. The code accomplishes two things:

1. Web scrapes and compiles the aforementioned text into one text file
2. (Optional) Opens the articles in your web browser
  
I have the output listed as a text file since it can be easily converted to an MP3 from this stage. There are many applications that one can use for this. My current favorite is [balabolka](https://www.cross-plus-a.com/balabolka.htm) because it is free to use, has a desktop application, and allows me to control the speed of the MP3 text-to-voice.

Opening the articles in a web browser can be nice if you would like to read along as the MP3 plays.

## Using this code

1. Input the URL for the AEA journal issue you want to read
2. Change the working directory for where you want the text file placed
3. Determine whether you want R to open the articles from this issue in a web browser

Examples are provided in the code.

[Source Code](https://github.com/joshmartinecon/aea-abstract-web-scraper/blob/main/aea%20abstract%20webscraper.R)
