################
## Nicer Maps ##
################
## Help with nicer map
# alpha_range = c(0.14, 0.75)
# size_range = c(0.134, 0.173)

## Create a title with subtitle in ggplot/ggmap
ggtitle_subtitle = function(title, subtitle = "") {
  
  ggtitle(bquote(atop(bold(.(title)), atop(.(subtitle)))))
  
}

## Black Theme Map
# fontCheck <- names(pdfFonts())

BlackTheme = function(base_size = 24) {
  
  theme_bw(base_size) +
    theme(text = element_text(color = "#ffffff"),
          rect = element_rect(fill = "#000000", color = "#000000"),
          plot.background = element_rect(fill = "#000000", color = "#000000"),
          panel.background = element_rect(fill = "#000000", color = "#000000"),
          plot.title = element_text(),
          panel.grid = element_blank(),
          panel.border = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          axis.ticks = element_blank())
  
}

