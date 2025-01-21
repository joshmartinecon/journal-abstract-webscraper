# The Issue

  - I read a lot for work 
  - I am time constrained
  - I am dyslexic
  
Converting the text from newly released academic papers to audio helps ameliorate these issues.

# The Solution

I've attached some code in R that I use to web scrape the text of the titles, authors and abstracts from issues that have recently been published in various academic journals. The code accomplishes three things:

1. Web scrapes and compiles the aforementioned text into one text file
2. (Optional) Opens the articles in your web browser if you want to read along
3. (Optional; not yet fully implemented) Converts the text to audio files

## Selenium WebDriver

Some of the code requires [RSelenium](https://cran.r-project.org/web/packages/RSelenium/index.html). Depending upon the browser you wish to use for this, you may need to install other programs such as [geckodriver](https://github.com/mozilla/geckodriver) or [docker-selenium](https://github.com/SeleniumHQ/docker-selenium). The code I provide uses Firefox but can be easily adjusted to use browsers such as Google Chrome if desired.

## MP3

Input is minimal by design, but the mp3 options require more work beforehand. 

1. You will need to install [Python](https://www.python.org/downloads/) for the [Google Text-to-Speech](https://pypi.org/project/gTTS/) ("gTTS") package

2. Install gTTS by running the following command in your system's command-line interface.

```bash
py -m pip install gTTS
```

3. Install the python interface package "[reticulate](https://cran.r-project.org/web/packages/reticulate/index.html)" in R.

```r
install.package("reticulate")
library(reticulate)
```
4. Convert the text to mp3 in R.

```r
gTTS <- import("gtts")
tts <- gTTS$gTTS(paste(unlist(text), collapse = " "), lang = "en")
tts$save("output.mp3")
```

**Continue along if you would like to speed up this audio output.**

5. Download [ffmpeg](https://www.gyan.dev/ffmpeg/builds/). I chose the "ffmpeg-git-essentials.7z" file. Extract it. Rename the folder "ffmpeg" for simplicity. Place this folder somewhere it will be easy to find. (I provide an example in steps 6 and 7.)

6. Add ffmpeg to the PATH.
    a. Open the **Start Menu**, search for “Edit the system environment variables” and open it.
    b. Click **Environment Variables**….
    c. Under **System variables**, find and select the **Path** variable, then click **Edit**.
    d. Click **New** and add the path to the **bin** directory, e.g.: C:\\ffmpeg\\bin
    e. Click **OK** to close all dialogs.
    f. **Restart** any open Command Prompts or R sessions so they pick up the new PATH.

7. Increase the playback speed of the audio file (previously saved as 'output.mp3'). Edit the speed as you choose with "atempo".

```r
ffmpeg_path <- "C:/ffmpeg/bin/ffmpeg.exe"
system(sprintf('"%s" -y -i output.mp3 -filter:a "atempo=2" "%s"', 
                 ffmpeg_path, 
                 "faster_output.mp3"))
  file.remove("output.mp3")
```

# Example

[Source Code](https://github.com/joshmartinecon/journal-abstract-webscraper/blob/main/wiley%20abstract%20webscraper.R)
