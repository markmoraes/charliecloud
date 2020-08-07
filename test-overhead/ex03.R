
################## LIBRARIES ######################################
library(plyr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(expss)
library(timelineS)
library(tidyr)
require(graphics)

############## READ FILES #########################################

e2e <- read.csv('ex03-E2E.csv')

######### PALETTE#################################################
colors <- c("#ba9bc9","#f2c9ee","#7575ac","#6b82b8","#f5cec1","#fbf9ed")
brighter_colors <- c("#cc66ff","#ffbdf8","#2424ff","#ffc9b8","#fffceb","#2465ff")
brighter_colors <- c("#2424ff","#cc66ff","#ffbdf8","#ffc9b8","#fffceb","#2465ff")
pastelles <- c("#ffbdf8","#bdfffb","#ffc8bd","#ccffbd","#ffbdbd")

palette(brighter_colors)
########### START PDF#############################################

pdf("ex03.pdf")


############# PLOT RAW ###########################################

# Plot End to End Times Raw
e2e <- e2e %>%
    mutate(e2e.sfsh = E_SFSH-S_SFSH) %>%
    mutate(e2e.sfsl = E_SFSL-S_SFSL) %>%
    mutate(e2e.psfsh = E_PSFSH-S_PSFSH) %>%
    select(TRIAL, RUN_COUNT,e2e.sfsh, e2e.sfsl, e2e.psfsh) %>%
    gather(Workflow, Duration,-TRIAL,-RUN_COUNT) %>%
    group_by(Workflow,RUN_COUNT) %>%
    summarize(Duration = mean(Duration))

e2e %>% ggplot(aes(x=RUN_COUNT, y=Duration, color=Workflow)) +
    geom_point(size=2) +
    geom_smooth(size=1.5) +
    labs(x="ch-run count",y="Duration(s)",title="Multiple Ch-Run Scaling") +
    scale_color_manual(values=palette()) +
    theme_bw() + 
    theme(text=element_text(size=30))

##################### END PDF ####################################
dev.off()
