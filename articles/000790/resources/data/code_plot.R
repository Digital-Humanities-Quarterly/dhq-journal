# these plots, intended for the DHQ submission, explore the theory corpus by source type, broken down 
# in several categories (e.g. theoretical field, date of composition, etc)
library(tidyverse)
library(ggsci)
library(ggpubr)
library(treemapify)
library(hrbrthemes)
library(viridis)


# data import
corpus_df <- read_csv(file = "2023-10-20_DHQ_corpus_data.csv") |> 
  mutate(source_type = str_to_title(source_type |> str_replace_all("_", " "))) |> 
  mutate(field = str_to_title(field |> str_replace_all("_", " "))) |> 
  # note factor ordering is locale-based
  mutate(field = factor(field)) |>
  mutate(source_type = factor(source_type)) |> 
  # annotate data with ebook / non
  mutate(born_digital = ifelse((source_type == "Ebook" | source_type == "Article"),
                              yes = "Born Digital",
                              no = "Digitized"))

# cached version for offline work
# -------------------------------
#write_rds(corpus_df, "corpus_df.rds")
#corpus_df <- read_rds("corpus_df.rds")

# generate consistent colour scale for plots
get_source_scale <- function(corpus_df, alpha){
  sources <- corpus_df |> 
    filter(!is.na(source_type)) |> 
    distinct(source_type) |> pull(source_type)
  # colours <- pal_jco()(length(sources))
  colours <- viridis(length(sources), alpha = alpha)
  names(colours) <- sources
  return(colours)
}
source_scale <- get_source_scale(corpus_df, alpha = 0.75)
source_scale_lite <- get_source_scale(corpus_df, alpha = 0.5)

######## Plots #########

# treemap of the corpus as a whole
# --------------------------------
# windowsFonts("Roboto Condensed" = windowsFont(("Roboto Condensed")))
corpus_df |> select(source_type) |> count(source_type, name = "count") |> 
  ggplot(aes(area = count,
             label = source_type,
             fill = source_type)) +
    geom_treemap(alpha = 0.75) +
    geom_treemap_text(aes(family = "Roboto Condensed"),
                      place = "center",
                      grow = FALSE,
                      reflow = TRUE,
                      size = 22) +
    geom_treemap_text(aes(label = count, family = "Roboto Condensed"),
      padding.x = grid::unit(2, "mm"),
      padding.y = grid::unit(2, "mm"),
      place = "bottomright",
      size = 14) +
    scale_fill_manual(values = source_scale) +
    theme(legend.position = "none",
      text = element_text(family = "Roboto Condensed"),
      plot.margin = margin(c(20, 20, 20, 20)))
ggsave("dhq_plots/overall_composition.svg", device = "svg",
       width = 8, height = 6, units = "in")

# treemap of print sources
corpus_df |> filter(source_type == "Print" | source_type == "Google Books") |> 
  count(source, name = "count") |>
  mutate(source = source |> str_replace_all("_", " ") |> str_to_title()) |> 
  ggplot(aes(area = count,
             label = source,
             fill = source)) +
  geom_treemap(alpha = 0.75) +
  geom_treemap_text(aes(family = "Roboto Condensed"),
                    place = "center",
                    grow = FALSE,
                    reflow = TRUE,
                    size = 22) +
  geom_treemap_text(aes(label = count, family = "Roboto Condensed"),
                    padding.x = grid::unit(2, "mm"),
                    padding.y = grid::unit(2, "mm"),
                    place = "bottomright",
                    size = 14) +
  scale_fill_viridis_d() +
  theme(legend.position = "none",
        text = element_text(family = "Roboto Condensed"),
        plot.margin = margin(c(20, 20, 20, 20)))
ggsave("dhq_plots/print_sources.svg", device = "svg",
       width = 8, height = 6, units = "in")

# box and whisker plot of age distribution for each source category
corpus_df |> separate_longer_delim(field, delim = " | ") |> 
    filter(!is.na(first_pub_date)) |> 
  ggplot(aes(y = first_pub_date, 
             x = source_type, 
             fill = source_type,
             color = "black")) +
    geom_boxplot(varwidth = TRUE, outlier.shape = NA) +
    geom_jitter(size=0.4, width = 0.25, height = 0) +
    ylab("Date of First Publication") +
    scale_y_continuous(breaks = seq(1850, 2025, 25)) +
    scale_color_manual(values = "black") + # not totally clear why this is needed
    scale_fill_manual(values = source_scale_lite) +
    theme_pubclean() +
    theme(text = element_text(family = "Roboto Condensed"),
          axis.line = element_line(linetype = "solid"),
          axis.text.x = element_text(angle = 65, hjust = 1.1),
          axis.title.x = element_blank(), legend.position = "none")
ggsave("dhq_plots/source_type_boxplot.svg", device = "svg",
       width = 6, height = 8, units = "in")

# density plot of relative proportion of born-digital texts by year
corpus_df |> group_by(born_digital) |> 
  ggplot(aes(x = first_pub_date, fill = born_digital)) + 
  geom_density(position = "fill", adjust = 0.5) +
  scale_fill_viridis_d(alpha = 0.75) +
  scale_x_continuous(expand = c(0,0), limits = c(1900, 2020)) +
  scale_y_continuous(labels = scales::label_percent(), expand = c(0,0)) +
  xlab(label = "Date of First Publication") +
  ylab(label = "Proportion") +
  labs(fill = "Source Type", caption = "Excludes 4 works from before 1900") +
  theme_pubclean() +
  theme(text = element_text(family = "Roboto Condensed"),
        plot.caption = element_text(face = "italic"),
        legend.position = "bottom", 
        axis.line = element_line(linetype = "solid"))
ggsave("dhq_plots/digital_proportion.svg", device = "svg",
       width = 6, height = 6, units = "in")


# the remaining code in this file generates a single multi-paned 
# plot showing source types for each field in two columns, with 
# overall counts on the left, and date-histograms on the right

source_type_plot <- function(corpus_df, target_field, title){
  p <- corpus_df |> select(source_type, field) |> 
      filter(field == target_field) |> 
    ggplot(aes(x = source_type, fill = source_type)) +
      geom_bar() +
      scale_x_discrete(drop = FALSE) +
      scale_fill_manual(values = source_scale, drop = FALSE) +
      scale_y_continuous(breaks = seq(0, 60, 10)) +
      labs(fill = "Source Type:", title = title) +
      ylab("Count") +
      theme_pubclean() +
      theme(text = element_text(family = "Roboto Condensed"),
            axis.title.y = element_blank(),
            legend.position = "bottom",
            axis.line = element_line(linetype = "solid")) +
      guides(fill = guide_legend(reverse = TRUE)) +
      coord_flip(ylim = c(0, 60), expand = FALSE)
  return(p)
}
# test case
# source_type_plot(corpus_df, "Marxism", "Marxism")

source_dates_plot <- function(df, target_field, title, scale_y_equal = FALSE){
  p <- df |>
      select(source_type, field, first_pub_date) |> 
      filter(field == target_field) |> 
    ggplot(aes(x = first_pub_date, fill = source_type)) +
      geom_histogram(colour = "black", binwidth = 10, boundary = 1900) +
      scale_x_continuous(breaks = seq(1910, 2020, 10)) +
      scale_fill_manual(values = source_scale) +
      coord_cartesian(xlim = c(1900,2020), expand = FALSE) +
      labs(title = title) +
      xlab("Date of First Publication") +
      theme_pubclean() +
      theme(text = element_text(family = "Roboto Condensed"),
            axis.title.y = element_blank(), 
            axis.line = element_line(linetype = "solid"))
  if (scale_y_equal) {
    y_lim <- 25
  } else {
    # painful computation of breaks so the y-axis can go by 5
    y_max <- max(ggplot_build(p)$data[[1]]|> group_by(x) |> summarise(total = sum(count)) |> pull(total))
    y_lim <- max((y_max %/% 5) * 5 + 5, 15) # ylim < 15 looks too small
  }
  p <- p + scale_y_continuous(labels = scales::label_number(accuracy = 1), 
                              breaks = seq(0, y_lim, 5), limits = c(0, y_lim))
  return(p)
}
# test case
# source_dates_plot(corpus_df |> 
#                      separate_longer_delim(field, delim = " | ") |> 
#                      filter(!is.na(source_type)) |> 
#                      filter(!is.na(first_pub_date)), "Russian Formalism", "Russian Formalism")

# option is provided to force equal y scales on all histograms
make_source_plots <- function(corpus_df, scale_y_equal = FALSE){
  corpus_df <- corpus_df |> 
    separate_longer_delim(field, delim = " | ") |> 
    filter(!is.na(source_type)) |> 
    filter(!is.na(first_pub_date))
  fields <- unique(corpus_df$field)
  plot_list <- vector(mode = "list", length = 2 * length(fields))
  for (i in seq_along(fields)){
    cur_field <- fields[i]
    cur_label <- cur_field |> str_replace_all("_", " ") |> str_to_title()
    type_p <- source_type_plot(corpus_df, cur_field, cur_label) # label left column
    dates_p <- source_dates_plot(corpus_df, cur_field, " ", scale_y_equal) # blank label (for spacing) on right column
    # remove x-axis labels from non-bottom plots
    if (i != length(fields)){
      type_p <- type_p +
        theme(axis.title = element_blank())
      dates_p <- dates_p +
        theme(axis.title = element_blank())
    }
    plot_list[[i * 2 - 1]] <- type_p
    plot_list[[i * 2]] <- dates_p
  }
  all_p <- ggarrange(plotlist = plot_list,
    nrow = 8, ncol = 2, align = "v",
    common.legend = TRUE, legend = "bottom") +
    theme(plot.margin = margin(5, 10, 5, 10, unit = "pt"))
  # add a caption
  all_p <- all_p |> 
    annotate_figure(bottom = text_grob("Histograms exclude 4 works published prior to 1900", 
                                       family = "Roboto Condensed", size = 12, face = "italic",
                                       hjust = 1, x = 0.99, y = 1))
  return(all_p)
}
# generate and save plots
make_source_plots(corpus_df)
ggsave("dhq_plots/field-source-types.svg", device = "svg",
       width = 12, height = 18, units = "in")
make_source_plots(corpus_df, scale_y_equal = TRUE)
ggsave("dhq_plots/field-source-types-fixed-scale.svg", device = "svg",
       width = 12, height = 18, units = "in")

