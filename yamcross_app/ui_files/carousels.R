
library("htmltools")
library("bsplus")


carousel <- 
  bs_carousel(id = "the_images", use_indicators = TRUE) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/7.jpg"),
    caption = bs_carousel_caption("","Barcoded field plant")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/9.jpg"),
    caption = bs_carousel_caption("","Bagged plants")
  ) %>%
  # bs_append(
  #   content = bs_carousel_image(src = "images/yam/8.jpg"),
  #   caption = bs_carousel_caption("","Barcoded bag")
  # ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/1.jpg"),
    caption = bs_carousel_caption("","Seedling germination")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/5.jpg"),
    caption = bs_carousel_caption("","Tuber storage")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/6.jpg"),
    caption = bs_carousel_caption("","Sprouting tubers")
  ) 