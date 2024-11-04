# QA of BC FISH PASS Gradient Estimates
# S Lingard
# Created October 15, 2024

library(tidyverse)
library(here)
library(lubridate)
library(ggpubr)

here()

dat <- read.csv(here("data","fiss_sample_sites_gradient.csv"))

QA <- dat %>% 
  filter(!is.na(surveyed_gradient))# 49k records with surveyed gradient.

names(dat)

# vertex to vertex measures occur on average over < 100 m
dat <- dat %>% 
  rowwise() %>%
  mutate(gradient_average=sum(gradient_upstr, gradient, gradient_dnstr)/3,
         gradient_average_len=sum(gradient_upstr_length, gradient_length, gradient_dnstr_length))


full.n <- nrow(dat)
filter.1 <- nrow(dat%>%filter(surveyed_length<=100))
filter.2 <- dat%>%filter(surveyed_length <=100) %>%
  drop_na(gradient, gradient100m, surveyed_gradient)%>%
  nrow()
# explore the data
# create long data format to make plotting easier

dat.long <- dat %>%
  select(surveyed_gradient, surveyed_length, gradient, gradient_length, gradient100m, gradient_average, gradient_average_len, stream_order)%>%
  gather(., key="variable", value="value", -stream_order)


dat.long %>%
  filter(stream_order<5)%>%
  filter(variable %in% c("gradient_length", "surveyed_length","gradient_average_len") & value < 200 | variable %in% c("surveyed_gradient","gradient","gradient100m", "gradient_average"))%>%
  ggplot(., aes(x=value))+
  geom_histogram()+
  facet_wrap(~variable, scales="free")


# gradients vars are right skewed, as is gradient_length

# averaging gradient for vertex to vetex

length(dat)


# trimming datset to qualities that make sense to compare. For example very difficult to measure 
# gradient using clinometer or laser at distance > 100 m in the field (in my expirience anyway)


trimmed.dat <- dat %>%
  filter(surveyed_length <= 100)%>%
  drop_na(gradient, gradient100m, surveyed_gradient, surveyed_length)%>%
  mutate(surveyed_gradient=abs(surveyed_gradient),
         gradient100m=abs(gradient100m))

# this results in a data set of ~20,399records by selecting only gradients surveyed over 100 m or less

n_order <- trimmed.dat%>%
  group_by(stream_order)%>%
  summarise(n())

# what to vertex to vertex lengths look like in trimmed df

trimmed.dat %>%
  group_by(stream_order)%>%
  ggplot(., aes(x=gradient_average_len))+
  geom_histogram()+
  facet_wrap(~stream_order, scales="free")


# correlations 
correlations <- trimmed.dat %>%
  group_by(stream_order)%>%
  filter(gradient_average_len < 1000)%>%
  summarise(r100m = cor(gradient100m, surveyed_gradient, method="pearson"),
            r = cor(gradient, surveyed_gradient, method="pearson"),
            r_average=cor(gradient_average, surveyed_gradient, method="pearson"),
            median_average_length=median(gradient_average_len))%>%
  merge(., n_order, by="stream_order")%>%
  round(., digits=2)

hundred.m <- trimmed.dat %>%
  filter(stream_order < 6)%>%
  ggplot(., aes(x=surveyed_gradient, y=gradient100m))+
  geom_point()+
  facet_wrap(~stream_order, scales="free")+
  stat_cor(aes(label = after_stat(r.label)), method="spearman")+
  labs(x="Field Surveyed Gradient (%)", 
       y="Gradient estimated 100m upstream of each vertex (%)")+
  theme_classic()+
  theme(axis.text=element_text(size=14),
        strip.text = element_text(size=14),
        axis.title=element_text(size=14))

ggsave(hundred.m, file=here("figures and tables", "spearman cor plots of 100 segs and surveyed.png"), 
       width=9, height=7)



v.to.v <- trimmed.dat %>%
  filter(surveyed_length <= 100 & stream_order < 7)%>%
  ggplot(., aes(x=surveyed_gradient, y=gradient))+
  geom_point()+
  facet_wrap(~stream_order, scales="free")+
  stat_cor(aes(label = after_stat(r.label)), method="spearman")+
  labs(x="Field Surveyed Gradient (%)", 
       y="V-V Estimates (%)")+
  theme_classic()+
  theme(axis.text=element_text(size=14),
        strip.text = element_text(size=14),
        axis.title=element_text(size=14))

ggsave(v.to.v, file=here("figures and tables", "spearman cor plots of v to v and surveyed.png"), 
       width=9, height=7)


avg.plot <- trimmed.dat %>%
  filter(surveyed_length <= 100 & stream_order < 7)%>%
  ggplot(., aes(x=surveyed_gradient, y=gradient_average))+
  geom_point()+
  facet_wrap(~stream_order, scales="free")+
  stat_cor(aes(label = after_stat(r.label)), method="spearman")+
  labs(x="Field Surveyed Gradient (%)", 
       y="Mean V-V Estimates (nearest to measure, up and downstream (%)")+
  theme_classic()+
  theme(axis.text=element_text(size=14),
        strip.text = element_text(size=14),
        axis.title=element_text(size=14))

ggsave(avg.plot, file=here("figures and tables", "spearman cor plots of v to v avg and surveyed.png"), 
       width=9, height=7)

# To Do: 

# Most sources indicate for skewed data with outliers (which I have both of), using spearman is more appropriate. 
# https://pubmed.ncbi.nlm.nih.gov/29481436/ & https://psycnet.apa.org/buy/2016-25478-001 
# Create R-markdown going through flow of data exploration, cleaning, correlations
# doesn't really matter what measure we use they are all roughly the same. There is some relationship for sure but also 
# likewise what we find in this model for gradients passed won't be very informative to biology
# Simon's method is most accurate based on this exercise.


