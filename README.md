# How Covid-19 preprints spread on Twitter

This Shiny app is a behind the scenes look at a selection of the preprint studies Jeff Howe and I wrote about in a May 14, 2020 piece in New York Times Opinion: ["A Study Said Covid Wasn’t That Deadly. The Right Seized It."](https://www.nytimes.com/2020/05/14/opinion/coronavirus-research-misinformation.html)

Explore the app [here](storybench.shinyapps.io/preprints-twitter/).

## Methods

Our analysis of 882 preprints published on medRxiv.org and shared on Twitter revealed two broad sharing patterns: In the first model, a few voices take a study and broadcast it to an army of retweeters. This one-to-many model, seen with the 'Indoor transmission of SARS-CoV-2' or the Santa Clara seroprevalence preprints, conforms most closely to traditional broadcast media, even as it bypasses traditional forms of vetting such as peer review or simple fact checking. 

The other model, seen with the 'Chloroquine diphosphate in two different dosages' preprint for instance, is equally interesting, and conforms more closely to a many-to-many model of information spread. In this scenario, the papers are usually taken up by researchers and academics debating its merits in real time, spreading it via Twitter in the process as they broadcast it to colleagues for discussion.

## Tools

This analysis was performed in RStudio using the packages 'tidyverse', 'rtweet' and 'twinetverse'. There may be gaps in the Twitter data, given the limitations with Twitter's free API tier. It should be noted that medRxiv URLs aren't very popular and we crossreferenced our data with software like 'twint' and 'hydrator' to spot-check for completeness.

![img](https://github.com/aleszu/preprints-twitter/blob/master/app-screenshot.001.jpeg)
