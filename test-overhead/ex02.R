
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

e2e <- read.csv('ex02-E2E.csv')
mt <- read.csv('ex02-MT.csv')
rt <- read.csv('ex02-RT.csv')
ut <- read.csv('ex02-UT.csv')

######### PALETTE#################################################
colors <- c("#ba9bc9","#f2c9ee","#7575ac","#6b82b8","#f5cec1","#fbf9ed")
brighter_colors <- c("#cc66ff","#ffbdf8","#2424ff","#2465ff","#ffc9b8","#fffceb")
pastelles <- c("#ffbdf8","#bdfffb","#ffc8bd","#ccffbd","#ffbdbd")

palette(brighter_colors)

########### START PDF#############################################

pdf("ex02.pdf")

########## PLOT TIMELINE ##########################################
all <- cbind(mt=select(mt,-ID),rt=select(rt,-ID),ut=select(ut,-ID))
g <- sapply(all, median) %>%
    t() %>%
    data.frame() %>%
    select(-rt.S_TB, -rt.E_TB) %>%
    gather()
g$key <- gsub("\\.", "_",g$key)
key<-cbind(g$value,colsplit(type.convert(g$key), "_", c("Phase","start", "group")))
df <- key %>% spread(-Phase,-group)
idf <- df %>% group_by(group) %>%
    mutate(fE = E - min(S)) %>%
    mutate(fS = S - min(S))
idf$group <- revalue(idf$group, c("SFSH"="Old SquashFS Workflow (High Level)",
    "SFSL" = "Old SquashFS Workflow (Low Level)",
    "PSFSH" = "New SquashFS Workflow (High Level)"))
idf$Phase <- revalue(idf$Phase, c("mt"="Mount Time",
    "ut"="Unmount Time",
    "rt"="Run Time"))
timelineG(df=idf, start="fS",end="fE", names="group",phase="Phase", width=7) +
    labs(x="Time (seconds)", y="Workflow", title = "Worfklows Timeline") +
    scale_y_discrete(labels=abbreviate) + 
    theme(text = element_text(size = 20))


############# PLOT RAW ###########################################

# Plot End to End Times Raw
e2e <- e2e %>%
    mutate(e2e.sfsh = E_SFSH-S_SFSH) %>%
    mutate(e2e.sfsl = E_SFSL-S_SFSL) %>%
    mutate(e2e.psfsh = E_PSFSH-S_PSFSH) %>%
    select(e2e.sfsh, e2e.sfsl, e2e.psfsh)
names(e2e) <- c("Old SquashFS Workflow (High Level)",
    "Old SquashFS Workflow (Low Level)",
    "New SquashFS Workflow(High Level)")
ggplot(melt(e2e), aes(x=value, y=variable, fill=variable)) +
    geom_boxplot(outlier.size=2, lwd=0.8) +
    scale_y_discrete(labels=abbreviate) +
    labs(title="Charliecloud Container Run Workflows") +
    labs(x="Duration (seconds)", y="Workflow") +
    scale_fill_manual(values=palette(), name = "Worfklow") +
    theme(text = element_text(size = 30), legend.position="none") +
    expand_limits(x=0)

# Plot Mount Times Raw
mt <- mt %>% mutate(mt.sfsh = E_SFSH-S_SFSH) %>%
    mutate(mt.sfsl = E_SFSL-S_SFSL) %>%
    mutate(mt.psfsh = E_PSFSH-S_PSFSH) %>%
    select(mt.sfsh, mt.sfsl, mt.psfsh)
names(mt) <- c("Old SquashFS Workflow (High Level)",
    "Old SquashFS Workflow (Low Level)",
    "New SquashFS Workflow(High Level)") 
ggplot(melt(mt), aes(x=value, y=variable, fill=variable)) +
    geom_boxplot(width = 0.5, outlier.size=2, lwd=0.8) +
    scale_y_discrete(labels=abbreviate) +
    labs(title="SquashFS Mount Times for Charliecloud Container Run Workflows") +
    labs(x="seconds", y="Workflow") +
    scale_fill_manual(values=palette(), name = "Worfklow") +
    theme(text = element_text(size = 30), legend.position="none") +
    expand_limits(x=c(0,0.07))

# Plot Unmount Times Raw
ut <- ut %>%
    mutate(ut.sfsh = E_SFSH-S_SFSH) %>%
    mutate(ut.sfsl = E_SFSL-S_SFSL) %>%
    mutate(ut.psfsh = E_PSFSH-S_PSFSH) %>%
    select(ut.sfsh, ut.sfsl, ut.psfsh)
names(ut) <- c("Old SquashFS Workflow (High Level)",
    "Old SquashFS Workflow (Low Level)",
    "New SquashFS Workflow(High Level)") 
ggplot(melt(ut), aes(x=value, y=variable, fill=variable)) +
    geom_boxplot(width=0.5, outlier.size=2, lwd=0.8) +
    scale_y_discrete(labels=abbreviate) +
    labs(title="SquashFS Unmount Times for Charliecloud Container Run Workflows") +
    labs(x="Unmount Time (s)", y="Workflow") +
    scale_fill_manual(values=palette(), name = "Worfklow") +
    theme(text = element_text(size = 30), legend.position="none") +
    expand_limits(x=c(0,0.07))

# Plot Run Times Raw
rt <- rt %>%
    mutate(rt.sfsh = E_SFSH-S_SFSH) %>%
    mutate(rt.sfsl = E_SFSL-S_SFSL) %>%
    mutate(rt.psfsh = E_PSFSH-S_PSFSH) %>%
    mutate(rt.tb = E_TB-S_TB) %>%
    select(rt.sfsh, rt.sfsl, rt.psfsh)
names(rt) <- c("Old SquashFS Workflow (High Level)",
    "Old SquashFS Workflow (Low Level)",
    "New SquashFS Workflow(High Level)")
#    "Tarball Worfklow")
ggplot(melt(rt), aes(x=value, y=variable, fill=variable)) + geom_boxplot(width=0.5) +
    scale_y_discrete(labels=abbreviate) +
    labs(title="Run Times for Charliecloud Container Run Workflows") +
    labs(x="Run Time (s)", y="Workflow") +
    scale_fill_manual(values=palette(), name = "Worfklow") +
    theme(text = element_text(size = 30), legend.position="none") +
    expand_limits(x=c(0,0.11))

##################### END PDF ####################################
dev.off()
